#!/usr/bin/env python3
"""run_gem_corpus.py — CRuby-vs-Spinel differential corpus for gem compatibility.

Two sections:

  A. synthetic: reference/gem_corpus/*.rb (MRI/Spinel style gem API, deterministic
     output) run under CRuby + raylib-bindings (the oracle) and under Spinel with
     raylib-spinel, then diffed.
  B. examples: the raylib-bindings examples (real MRI code) with only the loader
     line replaced by `require "raylib"` (the compat entry, so the full gem
     surface is loaded); each is analyzed with `spinel -c` to record whether
     unmodified gem-API code compiles.

  C. run: the asset-free examples from B actually RUN under CRuby and under
     Spinel, each under its own Xvfb for a few seconds; stdout, exit status and
     a screenshot (unique colours / mean brightness) are compared. This is the
     "compile/run unchanged" evidence: analysis alone cannot see a black
     render texture or a run-time TypeError.

Reports: reference/reports/gem_corpus.md (+ .json worklist). Skipped sections
keep their previous results (the report is merged, not replaced).
Usage: python3 tools/run_gem_corpus.py [--only synthetic|examples|run]
                                      [--run-examples NAME ...]
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


ASSET_ROOT = "/tmp/opencode/corpus_assets"

# The gem examples read their resources from the raylib-bindings checkout
# (raylib_dll/raylib/examples/*/resources), which is not vendored here. Build the
# few files the run set needs and point the RAYLIB_* constants at them: the GIF
# comes from ImageMagick, the TTF is copied from the system.
ASSET_CONSTANTS = """RAYLIB_MODELS_PATH = "%(root)s/models/"
RAYLIB_MODELS_SHADERS_PATH = "%(root)s/models/resources/shaders/"
RAYLIB_TEXT_PATH = "%(root)s/text/"
RAYLIB_TEXTURE_PATH = "%(root)s/textures/"
RAYLIB_AUDIO_PATH = "%(root)s/audio/"
RAYLIB_OTHERS_PATH = "%(root)s/others/"
RAYLIB_SHADERS_PATH = "%(root)s/shaders/resources/"
RAYGUI_STYLE_PATH = "%(root)s/styles/"
""" % {"root": ASSET_ROOT}


def synth_assets():
    for sub in ("textures/resources", "text/resources", "models/resources/shaders",
                "shaders/resources", "audio/resources", "others", "styles"):
        os.makedirs(os.path.join(ASSET_ROOT, sub), exist_ok=True)
    gif = os.path.join(ASSET_ROOT, "textures", "resources", "scarfy_run.gif")
    if not os.path.exists(gif):
        run(["convert", "-size", "32x32", "xc:#ffcc00", "-size", "32x32", "xc:#cc3300",
             "-size", "32x32", "xc:#3333cc", "-loop", "0", gif], ASSET_ROOT)
    ttf = os.path.join(ASSET_ROOT, "text", "resources", "anonymous_pro_bold.ttf")
    # the SDF example loads a fragment shader from the resource tree; a minimal
    # valid GLSL 330 shader is enough for the differential run (both engines
    # load the same file)
    shader = os.path.join(ASSET_ROOT, "text", "resources", "shaders", "glsl330", "sdf.fs")
    os.makedirs(os.path.dirname(shader), exist_ok=True)
    if not os.path.exists(shader):
        open(shader, "w").write("""#version 330

in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;
uniform vec4 colDiffuse;

out vec4 finalColor;

void main()
{
    vec4 texelColor = texture(texture0, fragTexCoord);
    finalColor = texelColor * colDiffuse * fragColor;
}
""")
    if not os.path.exists(ttf):
        for cand in ("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
                     "/usr/share/fonts/truetype/andika/Andika-Bold.ttf"):
            if os.path.exists(cand):
                shutil.copyfile(cand, ttf)
                break


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
    # resource paths: point the gem's constants at the synthesized assets
    for req in ("require_relative '%s/util/resource_path'" % EXAMPLES,
                'require_relative "%s/util/resource_path"' % EXAMPLES):
        if req in text:
            text = text.replace(req, ASSET_CONSTANTS.strip())
    open(dst, "w").write(text)
    return dst


# Examples that are broken against the raylib-bindings gem itself (verified
# under CRuby: the called method does not exist). They are reported as
# `invalid` and excluded from the 70-example target.
INVALID_EXAMPLES = {
    "models_animation_lowlevelapi.rb":
        "calls UnloadModelAnimation (singular); the loaded gem binds only the "
        "plural UnloadModelAnimations",
    "shapes_basic_shapes.rb":
        "calls DrawCircleGradient(x, y, radius, ...); the loaded gem binds the "
        "raylib-6 signature (Vector2 center, float radius, ...)",
    "textures_background_scrolling.rb":
        "calls unloadtexture (typo; NoMethodError under CRuby)",
    "models_animation_blending.gpu.rb":
        "calls UpdateModelAnimationBonesLerp (not in raylib 6.1 or gem 0.8.4; NoMethodError under CRuby)",
    "textures_bunnymark_optimized.rb":
        "calls Vector2#add! (not defined by the gem; NoMethodError under CRuby)",
    "text_font_sdf.rb":
        "calls LoadFontData with 6 arguments; the loaded gem binds 7 (the "
        "last a glyphCount out-pointer), so both engines raise ArgumentError",
    "rlgl_compute_shader.rb":
        "calls rlLoadComputeShaderProgram/rlCompileShader; the loaded gem exposes "
        "rlLoadShaderProgramCompute instead and has no rlCompileShader",
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


# ------------------------------------------------------------------- run --

# Asset-free examples from the analyzed set (no RAYLIB_*/resources paths; the
# gem's resource checkout is not present here). Audio is excluded: no device.
RUN_EXAMPLES = [
    "basic_loop.rb", "bitmap_font.rb", "core_2d_camera.rb",
    "core_3d_camera_first_person.rb", "core_3d_split_screen.rb",
    "core_automation_events.rb", "core_drop_files.rb", "core_loading_thread.rb",
    "core_world_screen.rb", "flocking_optimized.rb", "flocking_plain.rb",
    "game_of_life_simple.rb", "game_of_life_ui.rb", "gui_controls.rb",
    "lissajous_curve.rb", "models_box_collisions.rb",
    "models_geometric_shapes.rb", "models_mesh_generation.rb",
    "models_rlgl_solar_system.rb", "models_waving_cubes.rb",
    "particles_fireworks.rb", "physics_demo.rb", "procedural_texture.rb",
    "shapes_basic_shapes.rb", "shapes_draw_circle_sector.rb",
    "shapes_lines_bezier.rb", "snake_case_api.rb", "snake_case_rlgl.rb",
    "template.rb", "text_rectangle_bounds.rb", "textures_image_generation.rb", "textures_gif_player.rb",
    "textures_mouse_painting.rb", "toon_character_sprites.rb", "utf8_font.rb",
]

# Not run (reported as skipped): cwd-relative assets the checkout does not
# ship, or RubyGems reflection rather than the raylib API.
RUN_SKIP = {
    "utf8_font.rb": "reads ./jpfont/jpfont.txt relative to cwd (asset not present)",
    "snake_case_api.rb": "uses Gem::Specification (RubyGems API), not the raylib surface",
    "snake_case_rlgl.rb": "uses Gem::Specification (RubyGems API), not the raylib surface",
    "template.rb": "uses Gem::Specification (RubyGems API), not the raylib surface",
}

RUN_SECONDS = 4
SHOT_DIR = "/tmp/opencode/corpus_shots"

CAPTURE_SH = """#!/bin/bash
# $@ is the program; xvfb-run already provides DISPLAY.
"$@" >stdout.txt 2>stderr.txt &
pid=$!
sleep %(seconds)d
import -window root shot.png 2>/dev/null
kill $pid 2>/dev/null
wait $pid 2>/dev/null
echo $? > rc.txt
exit 0
"""

# the program was killed by the harness on purpose (SIGTERM), or exited by
# itself at the end of its own loop
OK_RC = {0, 143, 137}


def image_stats(path):
    """(unique colours, mean brightness, WxH) for a screenshot, or None."""
    if not os.path.exists(path):
        return None
    rc, out, _ = run(["identify", "-format", "%k %[fx:mean] %wx%h", path + "[0]"],
                     os.path.dirname(path), timeout=30)
    if rc != 0 or not out.strip():
        return None
    parts = out.split()
    if len(parts) == 3:
        # the mean flaps in the 5th decimal between identical runs; 4 decimals
        # keep the committed report stable
        try:
            parts[1] = "%.4f" % float(parts[1])
        except ValueError:
            pass
        return " ".join(parts)
    return out.strip()


def capture_run(argv, tmp, tag):
    """Run argv under xvfb, kill it after RUN_SECONDS, keep stdout + a frame."""
    helper = os.path.join(tmp, "capture.sh")
    open(helper, "w").write(CAPTURE_SH % {"seconds": RUN_SECONDS})
    run(["xvfb-run", "-a", "bash", helper] + argv, tmp, timeout=RUN_SECONDS + 90)
    def read(name, default=""):
        p = os.path.join(tmp, name)
        return open(p).read() if os.path.exists(p) else default
    shot = os.path.join(tmp, "shot.png")
    stats = image_stats(shot)
    if stats:
        os.makedirs(SHOT_DIR, exist_ok=True)
        shutil.copy(shot, os.path.join(SHOT_DIR, tag + ".png"))
    try:
        rc = int(read("rc.txt", "-1").strip() or -1)
    except ValueError:
        rc = -1
    return {"rc": rc, "stdout": normalize(read("stdout.txt")),
            "stderr": read("stderr.txt"), "shot": stats}


def run_example(src, flags):
    name = os.path.basename(src)
    out = {"name": name, "mri": None, "spinel": None}
    for kind in ("mri", "spinel"):
        with tempfile.TemporaryDirectory() as tmp:
            dst = prepare_example(src, tmp)
            if kind == "spinel":
                exe = os.path.join(tmp, "ex_bin")
                link = vendored_raylib_link(tmp)
                rc, _o, err = run(["spinel", dst] + flags + link + ["-o", exe],
                                  tmp, timeout=300)
                if rc != 0 or not os.path.exists(exe):
                    out["spinel"] = {"compile_error": first_spinel_error(err)}
                    continue
                argv = [exe]
            else:
                argv = ["ruby", "-I", ROOT, "-I", os.path.join(EXAMPLES, "util"), dst]
            out[kind] = capture_run(argv, tmp, "%s.%s" % (name[:-3], kind))
    mri, sp = out["mri"], out["spinel"]
    if isinstance(sp, dict) and "compile_error" in sp:
        out["verdict"], out["detail"] = "spinel-error", "compile: " + sp["compile_error"][:80]
    elif mri is None or mri["rc"] not in OK_RC:
        out["verdict"] = "mri-error"
        out["detail"] = "mri rc=%s %s" % (mri["rc"] if mri else "?", mri["stderr"].strip().splitlines()[-1][:60] if mri and mri["stderr"].strip() else "")
    elif sp["rc"] not in OK_RC:
        out["verdict"] = "spinel-error"
        out["detail"] = "spinel rc=%s %s" % (sp["rc"], sp["stderr"].strip().splitlines()[-1][:60] if sp["stderr"].strip() else "")
    elif sp["stdout"] != mri["stdout"]:
        out["verdict"], out["detail"] = "stdout-diff", "stdout differs"
    elif (not sp["shot"] or int(sp["shot"].split()[0]) < 3) and \
            mri["shot"] and int(mri["shot"].split()[0]) >= 3:
        out["verdict"], out["detail"] = "spinel-blank", "screenshot has no content: %s" % sp["shot"]
    else:
        out["verdict"] = "ran"
        out["detail"] = "mri shot=%s | spinel shot=%s" % (mri["shot"], sp["shot"])
    return out


def section_run(flags, names=None):
    wanted = names or RUN_EXAMPLES
    skipped = [{"name": n, "verdict": "skipped", "detail": RUN_SKIP[n]}
               for n in wanted if n in RUN_SKIP]
    files = [os.path.join(EXAMPLES, n) for n in wanted if n not in RUN_SKIP]
    synth_assets()
    files = [f for f in files if os.path.exists(f)]
    with ThreadPoolExecutor(max_workers=2) as ex:
        return skipped + list(ex.map(lambda f: run_example(f, flags), files))



def main():
    only = sys.argv[sys.argv.index("--only") + 1] if "--only" in sys.argv else None
    names = None
    if "--run-examples" in sys.argv:
        names = [a if a.endswith(".rb") else a + ".rb"
                 for a in sys.argv[sys.argv.index("--run-examples") + 1:]
                 if not a.startswith("--")]
    flags = spinel_flags()
    # merge: a section that is not re-run keeps its previous results
    old = {}
    old_path = os.path.join(REPORTS, "gem_corpus.json")
    if os.path.exists(old_path):
        try:
            old = json.load(open(old_path))
        except ValueError:
            old = {}
    result = {"synthetic": [], "examples": [], "run": []}
    if only == "run":
        result["synthetic"] = old.get("synthetic", [])
        result["examples"] = old.get("examples", [])
        rerun = section_run(flags, names)
        if names:
            keep = {r["name"]: r for r in old.get("run", [])}
            keep.update({r["name"]: r for r in rerun})
            result["run"] = [keep[k] for k in sorted(keep)]
        else:
            result["run"] = rerun
    else:
        if only != "examples":
            result["synthetic"] = section_synthetic(flags)
        else:
            result["synthetic"] = old.get("synthetic", [])
        if only != "synthetic":
            result["examples"] = section_examples(flags)
        else:
            result["examples"] = old.get("examples", [])
        result["run"] = old.get("run", [])

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

    if result["run"]:
        md.append("## Examples run (asset-free subset, CRuby vs Spinel under Xvfb)\n")
        md.append("| example | verdict | detail |")
        md.append("| --- | --- | --- |")
        for r in result["run"]:
            md.append("| %s | %s | %s |" % (r["name"], r["verdict"], r["detail"]))
        ok = sum(1 for r in result["run"] if r["verdict"] == "ran")
        md.append("\n%d/%d ran identically enough to render content under both engines "
                  "(screenshots kept in %s).\n" % (ok, len(result["run"]), SHOT_DIR))

    open(os.path.join(REPORTS, "gem_corpus.md"), "w").write("\n".join(md))
    print("\n".join(md))
    print("wrote", os.path.join(REPORTS, "gem_corpus.md"))


if __name__ == "__main__":
    main()
