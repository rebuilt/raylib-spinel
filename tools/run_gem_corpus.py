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


def delegators():
    """Generate the instance-method delegators the MRI gem provides.

    The gem attaches every function both as a module method and (after
    `include Raylib`) as an instance method; raylib-spinel only defines the
    module methods, so bare-call example code needs this prelude to analyze
    past the first blocker. Harness-only: prototypes P1's generation.
    """
    global PREAMBLE
    if PREAMBLE is not None:
        return PREAMBLE
    text = "\n".join(open(os.path.join(ROOT, "lib", f)).read()
                     for f in sorted(os.listdir(os.path.join(ROOT, "lib")))
                     if f.endswith("_ffi.rb"))
    lines = []
    for m in re.finditer(r"def self\.([A-Za-z]\w*)\(([^)]*)\)", text):
        name, args = m.group(1), m.group(2).strip()
        if name.startswith("rl_"):
            continue  # adapter shim, not gem surface
        lines.append("def %s(%s) = Raylib.%s(%s)" % (name, args, name, args))
    with_args = set(re.findall(r"def self\.([A-Za-z]\w*)\(", text))
    for name in sorted(set(re.findall(r"ffi_func\s+:([A-Za-z]\w*)", text)) - with_args):
        if name.startswith("rl_"):
            continue
        lines.append("def %s(*args) = Raylib.%s(*args)" % (name, name))
    PREAMBLE = "\n".join(sorted(set(lines)))
    return PREAMBLE


def mri_run(path, tmp):
    cmd = ["ruby", "-I", ROOT, "-I", CORPUS, path]
    if windowed(path):
        cmd = ["xvfb-run", "-a"] + cmd
    return run(cmd, tmp)


def spinel_run(path, flags, tmp):
    exe = os.path.join(tmp, "corpus_bin")
    build = run(["spinel", path] + flags + ["-o", exe], tmp, timeout=240)
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
    prelude = "\n".join([
        'require "raylib-spinel"',
        'require "raylib-spinel/raymath"',
        'require "raylib-spinel/rlgl"',
        'require "raylib-spinel/raygui"',
        'require "raylib-spinel/physac"',
        'require "raylib-spinel/rcamera"',
        "include Raylib",
        delegators(),
    ])
    text = text.replace("require_relative 'util/setup_dll'", prelude)
    text = text.replace('require_relative "util/setup_dll"', prelude)
    text = text.replace("require_relative 'util/", "require_relative '%s/util/" % EXAMPLES)
    text = text.replace('require_relative "util/', 'require_relative "%s/util/' % EXAMPLES)
    open(dst, "w").write(text)
    return dst


def analyze_example(src, flags):
    name = os.path.basename(src)
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
        bare = [r for r in result["examples"] if r["verdict"] == "bare-call"]
        if bare:
            md.append("First bare-call blocker (same shape for all %d):\n" % len(bare))
            md.append("```\n%s\n```\n" % bare[0]["detail"])

    open(os.path.join(REPORTS, "gem_corpus.md"), "w").write("\n".join(md))
    print("\n".join(md))
    print("wrote", os.path.join(REPORTS, "gem_corpus.md"))


if __name__ == "__main__":
    main()
