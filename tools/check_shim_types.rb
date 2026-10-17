#!/usr/bin/env ruby
# frozen_string_literal: true

# check_shim_types.rb -- flag C shims whose scalar parameter/return types
# disagree with the Ruby declaration that describes them.
#
# Why this exists: Spinel derives the prototype and the call site for a shim
# from its Ruby declaration, while the shim's real definition lives in a
# hand-written `*_adapter.c` compiled separately. When the two disagree the
# linker cannot tell, and the call goes through the wrong ABI:
#
#   * `ffi_func :rl_audio_SetSoundVolume, [:ptr, :float], :void` emits a wrapper
#     `void sp_ffi_...(void *, float)` aliased to `rl_audio_SetSoundVolume`, so
#     the float is passed in the low 32 bits of xmm0;
#   * the adapter defined `void rl_audio_SetSoundVolume(void *snd, double v)`
#     -- it reads all 64 bits as a double, i.e. a denormal, i.e. ~0.
#
# So `SetSoundVolume(sound, 1.0)` silently set the volume to zero (the audio
# scene was inaudible while `IsSoundPlaying` reported healthy) and
# `Raylib.Rectangle(1.0, 2.0, 8.0, 4.0)` returned (0, 0, 0, 0). The same defect
# hit `Vector2Scale`/`Vector2Rotate`/`Vector2Lerp` (the raymath demo's arguments
# arrived as ~0) and `Ptr#put_array_of_float32` (float32 writes were garbage).
#
# The expectation depends on the declaration form, because the two have
# different ABIs:
#
#   * `ffi_func`      : `:float` is C `float`  (the wrapper's prototype), so the
#                       shim must take `float`;
#   * `native_method` : `:float` is Spinel's `sp_float`, i.e. C `double`, so the
#                       field-accessor shims must take/return `double`
#                       (gen_field_index.py generates them that way).
#
# Only *scalar* classes (float / double / integer) are compared, on parameters
# and on return values: those are the ones whose width silently changes the
# value. Pointer/handle parameters are the other audit's business
# (check_shim_unwraps.py) and are ignored here so this report stays readable.
#
# Usage: ruby tools/check_shim_types.rb [lib_dir]
# Exit status: 0 when every declared shim agrees, 1 otherwise.

LIB = ARGV[0] || File.expand_path("../lib", __dir__)

# C type text -> scalar class (pointers are "not a scalar", so they are skipped)
def c_class(type)
  t = type.gsub(/\b(static|inline|const|volatile|register|extern)\b/, " ").gsub(/\s+/, " ").strip
  return :ptr if t.include?("*")
  return :f64 if t.match?(/\bdouble\b/)
  return :f32 if t.match?(/\bfloat\b/)
  return :int if t.match?(/\b(sp_int|sp_oint|int|long|unsigned|uint|size_t|intptr_t)\b/)
  :other
end

# declaration symbol + form -> expected C scalar class (nil = not compared)
def expected(sym, form)
  case sym.to_s.delete_prefix(":")
  when "float" then form == :ffi_func ? :f32 : :f64
  when "double" then :f64
  when "int", "int64", "uint", "size", "long" then :int
  end
end

def parse_sig(sig)
  if sig.start_with?("%i[")
    sig[/%i\[(.*)\]/m, 1].to_s.split
  else
    sig.scan(/:(\w+)/).flatten
  end
end

# declaration symbol -> ABI class (box / pointer / scalar), as the emitter sees it
def sym_class(sym, form)
  case sym.to_s.delete_prefix(":")
  when "any" then :box
  when "ptr", "str", "color", "object" then :ptr
  else expected(sym, form) # :f32 / :f64 / :int / nil
  end
end

# Do an ffi_func and a native_method for the same C symbol emit different
# prototypes? The native_method's parameters follow the receiver, so align from
# the right: the ffi_func normally has one extra leading `:ptr` (the view).
def abi_clash?(ffi, native)
  off = ffi[:syms].size - native[:syms].size
  return false if off.negative? # unknown shape; not this audit
  native[:syms].each_with_index do |sym, i|
    j = i + off
    next if j >= ffi[:syms].size
    a = sym_class(ffi[:syms][j], :ffi_func)
    b = sym_class(sym, :native_method)
    next if a.nil? || b.nil?
    return true if a != b
  end
  false
end

# --- declarations -----------------------------------------------------------
# ffi_func      :name, [types], :ret
# native_method :ruby_name, [types], :ret, "c_symbol"
decls = {}
conflicts = []
Dir[File.join(LIB, "**", "*.rb")].sort.each do |file|
  text = File.read(file)
  [
    [:ffi_func, /ffi_func\s+:(\w+)\s*,\s*(%i\[[^\]]*\]|\[[^\]]*\])\s*,\s*(:\w+)/m,
     ->(m) { [m[1], parse_sig(m[2]), m[3], m[1]] }],
    [:native_method, /native_method\s+:([\w=?]+[!?]?)\s*,\s*(%i\[[^\]]*\]|\[[^\]]*\])\s*,\s*(:\w+)\s*,\s*"([^"]+)"/m,
     ->(m) { [m[4], parse_sig(m[2]), m[3], m[1]] }],
  ].each do |form, re, build|
    pos = 0
    while (m = re.match(text, pos))
      name, syms, ret, ruby_name = build.call(m)
      line = text[0...m.begin(0)].count("\n") + 1
      where = "#{file}:#{line}"
      if decls[name] && decls[name][:form] != form
        # The same C function cannot be called through two ABIs: one wrapper
        # emits `void (*)(void *, void *)`, the other `void (*)(X *, sp_RbVal)`.
        conflicts << [name, decls[name], { form: form, syms: syms, where: where }]
      end
      decls[name] ||= { syms: syms, ret: ret, form: form, ruby_name: ruby_name, where: where }
      pos = m.end(0)
    end
  end
end

# --- definitions ------------------------------------------------------------
# `[static] [const] <ret> <name>(<params>) {` at the start of a line
DEF_RE = /^([A-Za-z_][^\n;{}]*?)\b(rl_\w+)\s*\(([^)]*)\)\s*\{/
defs = []
Dir[File.join(LIB, "**", "*.c")].sort.each do |file|
  text = File.read(file)
  pos = 0
  while (m = DEF_RE.match(text, pos))
    name, ret, params = m[2], m[1], m[3]
    pos = m.end(0)
    next if defs.any? { |d| d[:name] == name }
    types = params.split(",").map { |p| p.strip.sub(/\s*\**\s*\w+\s*(\[[^\]]*\])?\s*$/, "") }
    defs << { name: name, ret: ret, types: types, file: file, line: text[0...m.begin(0)].count("\n") + 1 }
  end
end

# --- compare ----------------------------------------------------------------
bad = []
defs.each do |d|
  decl = decls[d[:name]]
  next unless decl
  where = "#{d[:file]}:#{d[:line]}"
  if decl[:syms].size == d[:types].size
    d[:types].each_with_index do |ctype, i|
      cc = c_class(ctype)
      exp = expected(decl[:syms][i], decl[:form])
      next if cc == :other || exp.nil? || cc == :ptr
      next if cc == exp
      bad << ["arg#{i}", d[:name], ctype.strip, ":#{decl[:syms][i]}", where, decl[:where]]
    end
  end
  next if decl[:ret] == ":self" # returns the receiver; not a scalar comparison
  rc = c_class(d[:ret])
  exp = expected(decl[:ret], decl[:form])
  next if rc == :other || exp.nil? || rc == :ptr
  next if rc == exp
  bad << ["ret", d[:name], d[:ret].strip.empty? ? "void" : d[:ret].strip, decl[:ret], where, decl[:where]]
end

if bad.empty?
  puts "check_shim_types: #{defs.size} shim definitions, #{decls.size} declarations, no scalar type mismatch"
else
  warn "check_shim_types: #{bad.size} scalar type mismatch(es) between a shim and its declaration:"
  warn "For a `ffi_func`, `:float` is C `float` and must be passed in the low 32 bits of"
  warn "xmmN; for a `native_method`, `:float` is `sp_float` (C `double`). Fix the shim,"
  warn "not the call site.\n\n"
  bad.each do |kind, name, ctype, sym, where, decl_where|
    warn format("  %-5s %-34s C=%-9s decl=%-8s  %s  (%s)", kind, name, ctype, sym, where, decl_where)
  end
end

conflicts.reject! do |_name, first, second|
  ffi, native = first[:form] == :ffi_func ? [first, second] : [second, first]
  !abi_clash?(ffi, native)
end
unless conflicts.empty?
  warn "\ncheck_shim_types: #{conflicts.size} C function(s) declared both as ffi_func and native_method:"
  warn "Each form emits a different prototype for the same symbol (raw `void *` vs"
  warn "`sp_RbVal`), so one of the two call paths passes the wrong shape. Give the"
  warn "native_method its own C shim (e.g. rl_Foo_set_x_any).\n\n"
  seen = {}
  conflicts.each do |name, first, second|
    next if seen[name]
    seen[name] = true
    warn format("  %-38s %-9s %s   vs   %-13s %s", name, ":#{first[:form]}", first[:where], ":#{second[:form]}", second[:where])
  end
  exit 1
end

# A `native_method` *writer* may not take a `:ptr`. At a call site whose static
# type is known it would pass the view pointer raw, but in a multi-class TU a
# scene struct field of the same name makes the field write poly, and the poly
# dispatch hands the writer the *boxed* value -- invalid C ("expected void * but
# argument is of type sp_RbVal"). Declare such writers `[:any]` and unwrap the
# view with rl_h_unbox() in the shim; that works on both paths. This broke
# `spin run hello_raylib`/`make single` once Transform#rotation= existed and
# several scenes had a `rotation` field of their own.
ptr_writers = []
decls.each do |csym, d|
  next unless d[:form] == :native_method && d[:ruby_name].end_with?("=")
  d[:syms].each_with_index do |sym, i|
    ptr_writers << [d[:ruby_name], csym, i, d[:where]] if sym == "ptr"
  end
end

if ptr_writers.empty?
  puts "check_shim_types: no :ptr field writer (every writer takes a boxed [:any] value)"
  exit(bad.empty? ? 0 : 1)
end

warn "\ncheck_shim_types: #{ptr_writers.size} field writer(s) declared with a :ptr parameter:"
warn "A poly field write passes the boxed value, so a :ptr writer produces invalid C"
warn "in any TU that has a class with a same-named field. Declare it [:any] and"
warn "unwrap with rl_h_unbox() in the shim.\n\n"
ptr_writers.each do |name, csym, i, where|
  warn format("  %-24s arg%d  %-34s %s", name, i, csym, where)
end
exit 1
