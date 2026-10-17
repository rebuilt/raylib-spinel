#!/usr/bin/env ruby
# frozen_string_literal: true

# publish_readiness.rb — would somebody else's install actually work?
#
# Everything here is the shape of a real consumer, because that is the one
# view a package author cannot get from inside the development tree: the
# gemspec's `s.files` and spin's `[package] sources` are two different answers
# to "what is this package", the carried C is compiled on the consumer's
# machine, and their loader has to find libraylib too. The measurements behind
# PACKAGING.md grew out of exactly these steps; this script is those steps, so
# the check can be re-run instead of re-remembered.
#
#   ruby tools/publish_readiness.rb            # static checks + consumer matrix
#   ruby tools/publish_readiness.rb --fast     # static checks only (seconds)
#   ruby tools/publish_readiness.rb --keep     # leave the scratch tree behind
#
# Gates (a FAIL here is a packaging regression): the two channels agree on the
# version; `s.files` ships no build output and does ship both entry points;
# every .c in the tree is either declared carried C or excluded from spin's
# sweep; a fresh clone builds from a git URL and runs — including the
# raylib-bindings preamble (`Gem::Specification.find_by_name` +
# `Raylib.load_lib`); `spin vendor` builds and runs from vendor/; the
# installed gem answers `require "raylib-spinel"` under MRI, and `require
# "raylib"` still answers raylib-bindings there (our entry must not shadow the
# real gem; see PACKAGING.md).
#
# Notes (reported, never fatal): no git remote, a dirty tree, no xvfb. Those
# are facts about the machine, not defects in the package.

require "fileutils"
require "tmpdir"

ROOT = File.expand_path("..", __dir__)
FAST = ARGV.include?("--fast")
KEEP = ARGV.include?("--keep")

$results = []

# Each check block returns [ok, note]; an exception is a FAIL with its message.
def check(name, gate = true)
  ok, note = yield
  $results << [name, ok, note, gate]
  puts(format("%-6s %s%s", ok ? "PASS" : (gate ? "FAIL" : "note"), name,
              note.to_s.empty? ? "" : " — #{note}"))
rescue StandardError => e
  $results << [name, false, "#{e.class}: #{e.message}", gate]
  puts(format("%-6s %s — %s: %s", gate ? "FAIL" : "note", name, e.class, e.message))
end

# `timeout` the program, not just Ruby's wait: a hung compiler must not hang
# the gate. Array spawn, so no shell quoting anywhere; child stderr joins the
# captured output so a build failure's own diagnosis is what gets reported.
def run(*cmd, chdir: nil, timeout: 1_800, env: {})
  opts = { err: [:child, :out] }
  opts[:chdir] = chdir if chdir # opts chdir: nil raises TypeError, so omit it
  out = IO.popen(env, ["timeout", timeout.to_s, *cmd], opts, &:read)
  [($?.success? rescue false), out]
end

def have?(prog)
  ENV.fetch("PATH", "").split(File::PATH_SEPARATOR)
     .any? { |d| File.executable?(File.join(d, prog)) }
end

# --- spin.toml, read the way spin's own reader reads it: single-line arrays ---
def spin_manifest
  txt = File.read(File.join(ROOT, "spin.toml"))
  arr = lambda do |key|
    m = txt.match(/^#{key}\s*=\s*\[(.*)\]\s*$/)
    m ? m[1].scan(/"([^"]*)"/).flatten : []
  end
  {
    name: txt[/^name\s*=\s*"([^"]*)"/, 1],
    version: txt[/^version\s*=\s*"([^"]*)"/, 1],
    sources: arr.call("sources"),
    exclude: arr.call("exclude")
  }
end

# --- the program the consumer matrix builds -----------------------------------
# A game written for the gem: raylib-bindings' own examples/template.rb
# preamble, then a draw loop through Raylib.* only. It exits after a few
# frames so the matrix needs no kill timer beyond the display.
APP = <<~'RUBY'
  # frozen_string_literal: true
  require "raylib"

  shared_lib_path = Gem::Specification.find_by_name("raylib-bindings").full_gem_path + "/lib/"
  Raylib.load_lib(shared_lib_path + "libraylib.so",
                  raygui_libpath: shared_lib_path + "raygui.so",
                  physac_libpath: shared_lib_path + "physac.so")

  include Raylib

  Raylib.InitWindow(320, 240, "publish_readiness")
  frames = 0
  until Raylib.WindowShouldClose
    Raylib.BeginDrawing
    Raylib.ClearBackground(Raylib::RAYWHITE)
    Raylib.DrawText("ok #{frames}", 20, 20, 20, Raylib::BLACK)
    Raylib.EndDrawing
    frames += 1
    break if frames > 3
  end
  Raylib.CloseWindow
  puts "consumer: ran #{frames} frames"
RUBY

# --- static channel checks ----------------------------------------------------
manifest = spin_manifest
gemspec_path = Dir[File.join(ROOT, "*.gemspec")].first
abort "no .gemspec at #{ROOT}" unless gemspec_path
spec = Gem::Specification.load(gemspec_path)
abort "#{gemspec_path} does not load" unless spec

check "channels agree on the version" do
  same = manifest[:version] == spec.version.to_s
  [same, same ? "#{spec.version} in both" : "gem #{spec.version} vs spin.toml #{manifest[:version].inspect}"]
end

check "gemspec ships both entry points and no build output" do
  need = ["raylib.rb", "raylib-spinel.rb", "spin.toml", "README.md", "lib/raylib_ffi.rb"]
  missing = need.reject { |f| spec.files.include?(f) }
  junk = spec.files.grep(/\.(?:o|c|gem)\z/)
  stray = spec.files.grep(%r{\A(?:tools|reference|test|build)/})
  ok = missing.empty? && junk.empty? && stray.empty?
  [ok, ok ? "#{spec.files.size} files" : "missing #{missing.inspect}; build output #{junk.inspect}; dev tree #{stray.inspect}"]
end

check "gemspec metadata is filled in" do
  bad = []
  bad << "summary duplicates description" if spec.summary == spec.description
  bad << "no required_ruby_version" if spec.required_ruby_version.nil? || spec.required_ruby_version.none?
  bad << "no license" if Array(spec.licenses).empty?
  bad << "no homepage" if spec.homepage.to_s.empty?
  [bad.empty?, bad.empty? ? "#{spec.licenses.join(", ")}, ruby #{spec.required_ruby_version}" : bad.join(", ")]
end

check "spin's C sweep finds nothing undeclared" do
  # spin walks the package for .c and warns, once per consumer build, about
  # every one [package] sources does not name and [package] exclude does not
  # prune. This mirrors that walk (dot dirs and build/ are skipped by both).
  excluded = manifest[:exclude].map { |g| File.join(ROOT, g) }
  pruned = ->(p) { excluded.any? { |x| p == x || p.start_with?("#{x}/") } }
  undeclared = []
  stack = [ROOT]
  until stack.empty?
    dir = stack.pop
    Dir.children(dir).sort.each do |entry|
      p = File.join(dir, entry)
      next if entry.start_with?(".") || entry == "build" || pruned.call(p)
      if File.directory?(p)
        stack << p
      elsif entry.end_with?(".c")
        rel = p[(ROOT.length + 1)..]
        undeclared << rel unless manifest[:sources].include?(rel)
      end
    end
  end
  [undeclared.empty?,
   undeclared.empty? ? "#{manifest[:sources].size} sources, exclude #{manifest[:exclude].inspect}" :
   "#{undeclared.size} .c would warn: #{undeclared.join(", ")}"]
end

check "spin manifest is publish-shaped" do
  ok = !manifest[:name].to_s.empty? && !manifest[:version].to_s.empty?
  [ok, "#{manifest[:name]} #{manifest[:version]}"]
end

check "git remote exists (publishing prerequisite)", false do
  url = IO.popen(["git", "-C", ROOT, "remote", "get-url", "origin"],
                 err: [:child, :out], &:read).strip
  ok = ($?.success? rescue false)
  [ok, ok ? url : "no origin — spin add --git and spin publish are both blocked"]
end

check "tree is clean", false do
  dirty = IO.popen(["git", "-C", ROOT, "status", "--porcelain"], &:read).lines.size
  [dirty.zero?, dirty.zero? ? "clean" : "#{dirty} changed (spin publish refuses a dirty tree)"]
end

# --- the consumer matrix ------------------------------------------------------
scratch = nil
if !FAST
  scratch = Dir.mktmpdir("raylib-publish-", Dir.exist?("/tmp/opencode") ? "/tmp/opencode" : Dir.tmpdir)
  pkg = File.join(scratch, "raylib-spinel")
  app = File.join(scratch, "consumer")
  xvfb = have?("xvfb-run") ? ["xvfb-run", "-a"] : []
  puts "\nscratch: #{scratch}"
  puts "note:    no xvfb-run, consumer runs need a display" if xvfb.empty?

  check "a fresh clone builds from a git URL" do
    ok, out = run("git", "clone", "-q", "--no-hardlinks", ROOT, pkg)
    next [ok, out.lines.last.to_s.strip] unless ok
    # A clone with the build output gone is the state a consumer sees; if any
    # rule or shim ever comes to depend on a tracked .o, this is where it shows.
    objs = Dir[File.join(pkg, "lib/*.o")].size
    FileUtils.mkdir_p(app)
    ok, out = run("spin", "init", chdir: app)
    next [ok, out.lines.last.to_s.strip] unless ok
    FileUtils.mkdir_p(File.join(app, "bin"))
    File.write(File.join(app, "bin", "app.rb"), APP)
    ok, out = run("spin", "add", "raylib", "--git", "file://#{pkg}", chdir: app)
    next [ok, out.lines.last.to_s.strip] unless ok
    ok, out = run("spin", "build", chdir: app)
    noise = out.lines.grep(/not named by/).size
    ran = File.executable?(File.join(app, "build/bin/app"))
    [ok && ran && noise.zero?,
     "objects in clone: #{objs}; undeclared-C warnings: #{noise}; binary: #{ran}"]
  end

  check "the gem preamble runs from the installed package" do
    ok, out = run(*xvfb, File.join(app, "build/bin/app"), chdir: app, timeout: 180)
    frames = out[/consumer: ran (\d+) frames/, 1]
    [ok && !frames.nil? && frames.to_i > 0,
     frames ? "ran #{frames} frames" : out.lines.last(3).join.strip]
  end

  check "the same dep vendored into vendor/ builds and runs" do
    ok, out = run("spin", "vendor", chdir: app)
    next [ok, out.lines.last.to_s.strip] unless ok
    FileUtils.rm_rf(File.join(app, "build"))
    ok, out = run("spin", "build", chdir: app)
    next [ok, out.lines.last(3).join.strip] unless ok
    ok, out = run(*xvfb, File.join(app, "build/bin/app"), chdir: app, timeout: 180)
    frames = out[/consumer: ran (\d+) frames/, 1]
    [ok && !frames.nil?, "vendor/#{Dir.children(File.join(app, "vendor")).join("/")} built, ran #{frames} frames"]
  end

  check "the gem installs and answers require \"raylib-spinel\" under MRI" do
    ok, out = run("gem", "build", File.basename(gemspec_path), chdir: ROOT)
    built = Dir[File.join(ROOT, "#{spec.name}-#{spec.version}.gem")]
    next [false, ok ? "gem build wrote nothing" : out.lines.last.to_s.strip] if built.empty?
    home = File.join(scratch, "gemhome")
    ok, out = run("gem", "install", "--local", "--force", "--no-document",
                  "--install-dir", home, built.first, timeout: 300)
    next [ok, out.lines.last.to_s.strip] unless ok
    # Both invariants of the MRI channel at once: our entry loads the real
    # gem's API (functions attached), and `require "raylib"` still resolves to
    # raylib-bindings, because activating ours activates it first. (The
    # interpolations the *generated* probe needs are escaped.)
    probe = <<~RB
      gem "#{spec.name}"
      require "#{spec.name}"
      raise "require #{spec.name} did not attach Raylib.InitWindow" unless Raylib.respond_to?(:InitWindow)
      require "raylib"
      answer = $LOADED_FEATURES.select { |f| f.end_with?("/raylib.rb") }.last.to_s
      raise "require raylib answered \#{answer.inspect}, not raylib-bindings" unless answer.include?("raylib-bindings")
      puts "MRI: \#{Raylib.constants.size} Raylib constants, require raylib -> \#{answer.split("/lib/raylib.rb").first.split("/").last}"
    RB
    ok, out = run("ruby", "-e", probe, env: { "GEM_PATH" => ([home] + Gem.path).join(File::PATH_SEPARATOR) }, timeout: 180)
    [ok, ok ? out.lines.last.to_s.strip : out.lines.last(3).join.strip]
  ensure
    Dir[File.join(ROOT, "#{spec.name}-*.gem")].each { |g| File.delete(g) unless KEEP }
  end
end

# --- report -------------------------------------------------------------------
fails = $results.select { |_, ok, _, gate| !ok && gate }
notes = $results.select { |_, _, _, gate| !gate }
puts
puts format("%d checks, %d failures, %d noted", $results.size, fails.size, notes.size)
notes.each do |name, ok, note, _|
  puts "  #{ok ? "ok  " : "note"} #{name}#{note.to_s.empty? ? "" : " — #{note}"}"
end
if scratch
  if KEEP
    puts "scratch kept at #{scratch}"
  else
    FileUtils.rm_rf(scratch)
  end
end
exit(fails.empty? ? 0 : 1)
