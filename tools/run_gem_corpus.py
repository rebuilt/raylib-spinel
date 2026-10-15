#!/usr/bin/env python3
"""run_gem_corpus.py — CRuby-vs-Spinel differential corpus for gem compatibility.

Two sections:

  A. synthetic: reference/gem_corpus/*.rb (MRI/Spinel style gem API, deterministic
     output) run under CRuby + raylib-bindings (the oracle) and under Spinel with
     raylib-spinel, then diffed.
  B. examples: the raylib-bindings examples (real MRI code) with only the loader
     line replaced by `require "raylib-spinel"`; each is analyzed with
     `spinel -c` to record whether unmodified gem-API code compiles.

Reports: reference/reports/gem_corpus.md (+ .json worklist).
Usage: python3 tools/run_gem_corpus.py [--only synthetic|examples]
"""

import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CORPUS = os.path.join(ROOT, "reference", "gem_corpus")
EXAMPLES = os.path.join(os.path.dirname(ROOT), "raylib-bindings", "examples")
REPORTS = os.path.join(ROOT, "reference", "reports")
TIMEOUT = 40


def spinel_flags():
    out = subprocess.run(["spin", "flags"], cwd=ROOT, capture_output=True,
                         text=True, timeout=300).stdout
    for line in reversed(out.strip().splitlines()):
        if line.startswith("--require-gate"):
            return line.split()
    raise SystemExit("run_gem_corpus: could not read `spin flags`")


def run(cmd, cwd, timeout=TIMEOUT):
    try:
        p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True,
                           timeout=timeout)
        return p.returncode, p.stdout, p.stderr
    except subprocess.TimeoutExpired:
        return 124, "", "timeout"


def windowed(path):
    with open(path) as f:
        return "# windowed" in f.read(400)


def normalize(text):
    """Drop raylib's own INFO/WARNING logging (GPU details differ per run)."""
    return "\n".join(l for l in text.splitlines()
                     if not re.match(r"^(INFO|WARNING):", l)).strip()


PREAMBLE = None


def mri_run(path, tmp):
    cmd = ["ruby", "-I", ROOT, "-I", CORPUS, path]
    if windowed(path):
        cmd = ["xvfb-run", "-a"] + cmd
    return run(cmd, tmp)


def vendored_raylib_so():
    """Path to the libraylib bundled by the installed raylib-bindings gem.

    The system libraylib creates incomplete FBOs on this box, so render-texture
    readbacks come back all zero; the gem's build is the known-good one (the
    hello_raylib Makefile vendors the same file). None when absent.
    """
    code = ('begin; s=Gem::Specification.find_by_name("raylib-bindings");'
            'arch=RUBY_PLATFORM.split("-")[0];'
            'p=Dir[File.join(s.full_gem_path,"lib","libraylib."+arch+".so")].first;'
            'print p if p; rescue StandardError; end')
    try:
        out = subprocess.check_output(["ruby", "-e", code], text=True,
                                      stderr=subprocess.DEVNULL).strip()
    except Exception:
        return None
    return out or None


def _soname(path):
    for tool in (["objdump", "-p"], ["readelf", "-d"]):
        try:
            out = subprocess.check_output(tool + [path], text=True,
                                          stderr=subprocess.DEVNULL)
        except Exception:
            continue
        m = re.search(r"SONAME\s+(\S+)", out)
        if m:
            return m.group(1).strip()
    return None


def vendored_raylib_link(tmp):
    """Link args for the gem's libraylib, symlinked under the SONAME it needs."""
    src = vendored_raylib_so()
    if not src:
        return []
    link_dir = os.path.join(tmp, "vlib")
    os.makedirs(link_dir, exist_ok=True)
    names = ["libraylib.so", "libraylib.so.600"]
    so = _soname(src)
    if so:
        names.append(so)
    for name in names:
        dst = os.path.join(link_dir, name)
        if not os.path.exists(dst):
            os.symlink(src, dst)
    return ["--link", "-L" + link_dir, "--link", "-Wl,-rpath," + link_dir]


def spinel_run(path, flags, tmp):
    exe = os.path.join(tmp, "corpus_bin")
    link = vendored_raylib_link(tmp)
    build = run(["spinel", path] + flags + link + ["-o", exe], tmp, timeout=240)
    if build[0] != 0 or not os.path.exists(exe):
        return "compile-error", build[1], build[2]
    cmd = [exe]
    if windowed(path):
        cmd = ["xvfb-run", "-a", exe]
    rc, out, err = run(cmd, tmp)
    return ("timeout" if rc == 124 else
            "run-error" if rc != 0 else "ran"), out, err


def first_spinel_error(stderr):
    for line in stderr.splitlines():
        if line.startswith("spinel:"):
            return line[len("spinel:"):].strip()
    for line in reversed(normalize(stderr).splitlines()):
        if line.strip():
            return line.strip()[:200]
    return ""


def section_synthetic(flags):
    rows = []
    for name in sorted(os.listdir(CORPUS)):
        if not name.endswith(".rb"):
            continue
        path = os.path.join(CORPUS, name)
        with tempfile.TemporaryDirectory() as tmp:
            m_rc, m_out, m_err = mri_run(path, tmp)
            if m_rc != 0:
                rows.append({"name": name, "verdict": "mri-error",
                             "detail": first_spinel_error(m_err)})
                continue
            verdict, s_out, s_err = spinel_run(path, flags, tmp)
            if verdict == "compile-error":
                detail = first_spinel_error(s_err)
            elif verdict != "ran":
                detail = "%s: %s" % (verdict, first_spinel_error(s_out + "\n" + s_err))
            elif normalize(m_out) != normalize(s_out):
                detail = "output differs"
            else:
                detail = ""
            rows.append({"name": name,
                         "verdict": "same" if verdict == "ran" and not detail else
                                    (verdict if verdict != "ran" else "output-diff"),
                         "detail": detail})
    return rows


def prepare_example(src, dst_dir):
    dst = os.path.join(dst_dir, os.path.basename(src))
    text = open(src).read()
    # The gem projects start with `require_relative 'util/setup_dll'`, which
    # loads the gem DLL and ends with `include Raylib`; replace the loader with
    # the gem's own entry point (`require "raylib"`, resolved to the compat
    # entry through -I ROOT) and keep the include so bare calls still work.
    for old in ("require_relative 'util/setup_dll'",
                'require_relative "util/setup_dll"'):
        text = text.replace(old, 'require "raylib"\ninclude Raylib')
    text = text.replace("require '../lib/raylib'", 'require "raylib"')
    text = text.replace('require "../lib/raylib"', 'require "raylib"')
    text = text.replace("require 'raylib'", 'require "raylib"')
    text = text.replace("require_relative 'util/", "require_relative '%s/util/" % EXAMPLES)
    text = text.replace('require_relative "util/', 'require_relative "%s/util/' % EXAMPLES)
    open(dst, "w").write(text)
    return dst


# Examples that are broken against the raylib-bindings gem itself (verified
# under CRuby: the called method does not exist). They are reported as
# `invalid` and excluded from the 70-example target.
INVALID_EXAMPLES = {
    "textures_background_scrolling.rb":
        "calls unloadtexture (typo; NoMethodError under CRuby)",
    "models_animation_blending.gpu.rb":
        "calls UpdateModelAnimationBonesLerp (not in raylib 6.1 or gem 0.8.4; NoMethodError under CRuby)",
    "textures_bunnymark_optimized.rb":
        "calls Vector2#add! (not defined by the gem; NoMethodError under CRuby)",
}


def analyze_example(src, flags):
    name = os.path.basename(src)
    if name in INVALID_EXAMPLES:
        return {"name": name, "verdict": "invalid",
                "detail": INVALID_EXAMPLES[name]}
    with tempfile.TemporaryDirectory() as tmp:
        dst = prepare_example(src, tmp)
        rc, _out, err = run(["spinel", "-c", dst] + flags +
                            ["-o", os.path.join(tmp, "out.c")], tmp, timeout=240)
        if rc == 0:
            return {"name": name, "verdict": "analyzed"}
        detail = first_spinel_error(err)
        kind = "bare-call" if "unsupported call" in detail else "refusal"
        return {"name": name, "verdict": kind, "detail": detail}


def section_examples(flags):
    files = sorted(f for f in os.listdir(EXAMPLES) if f.endswith(".rb"))
    with ThreadPoolExecutor(max_workers=4) as ex:
        return list(ex.map(lambda f: analyze_example(os.path.join(EXAMPLES, f), flags),
                           files))


def main():
    only = sys.argv[sys.argv.index("--only") + 1] if "--only" in sys.argv else None
    flags = spinel_flags()
    result = {"synthetic": [], "examples": []}
    if only != "examples":
        result["synthetic"] = section_synthetic(flags)
    if only != "synthetic":
        result["examples"] = section_examples(flags)

    os.makedirs(REPORTS, exist_ok=True)
    json.dump(result, open(os.path.join(REPORTS, "gem_corpus.json"), "w"), indent=1)

    md = ["# gem corpus results\n",
          "Tool: `tools/run_gem_corpus.py`. Oracle: CRuby + raylib-bindings; "
          "Spinel: `spinel` with `spin flags`.\n"]
    if result["synthetic"]:
        md.append("## Synthetic corpus (CRuby vs Spinel, same output)\n")
        md.append("| program | verdict | detail |")
        md.append("| --- | --- | --- |")
        for r in result["synthetic"]:
            md.append("| %s | %s | %s |" % (r["name"], r["verdict"], r["detail"]))
        same = sum(1 for r in result["synthetic"] if r["verdict"] == "same")
        md.append("\n%d/%d run identically under both engines.\n"
                  % (same, len(result["synthetic"])))
    if result["examples"]:
        md.append("## raylib-bindings examples (loader line replaced, `spinel -c`)\n")
        counts = {}
        for r in result["examples"]:
            counts[r["verdict"]] = counts.get(r["verdict"], 0) + 1
        md.append("| verdict | count |")
        md.append("| --- | --- |")
        for k, v in sorted(counts.items()):
            md.append("| %s | %d |" % (k, v))
        md.append("\n%d examples total.\n" % len(result["examples"]))
        invalid = [r for r in result["examples"] if r["verdict"] == "invalid"]
        if invalid:
            md.append("\nInvalid upstream (excluded from the target):\n")
            for r in invalid:
                md.append("- %s — %s" % (r["name"], r["detail"]))
        bare = [r for r in result["examples"] if r["verdict"] == "bare-call"]
        if bare:
            md.append("First bare-call blocker (same shape for all %d):\n" % len(bare))
            md.append("```\n%s\n```\n" % bare[0]["detail"])

    open(os.path.join(REPORTS, "gem_corpus.md"), "w").write("\n".join(md))
    print("\n".join(md))
    print("wrote", os.path.join(REPORTS, "gem_corpus.md"))


if __name__ == "__main__":
    main()
