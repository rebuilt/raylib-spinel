# physac_ffi.rb — physac bindings for Spinel AOT.
#
# physac is compiled into lib/physac_adapter.o + lib/physac_impl.o and linked
# into the physics scene. PhysicsBody is an opaque pointer; body creation takes
# raw floats (Vector2 by value). Loaded by `require "raylib-spinel/physac"`.
# Under CRuby the raylib-bindings gem already binds physac.

module Raylib
  ffi_lib "raylib"
  ffi_cflags "-I/usr/local/include"

# ====== generated: complete physac API surface ======
  ffi_func :InitPhysics, [], :void
  ffi_func :UpdatePhysics, [], :void
  ffi_func :ResetPhysics, [], :void
  ffi_func :ClosePhysics, [], :void
  ffi_func :SetPhysicsTimeStep, [:double], :void
  ffi_func :SetPhysicsGravity, [:float, :float], :void
  ffi_func :rl_PhysicsShatter, [:ptr, :ptr, :float], :void
  ffi_func :rl_SetPhysicsBodyRotation, [:ptr, :float], :void
  ffi_func :GetPhysicsBodiesCount, [], :int
  ffi_func :GetPhysicsShapeType, [:int], :int
  ffi_func :GetPhysicsShapeVerticesCount, [:int], :int

  ffi_func :rl_InitPhysics, [], :ptr
  ffi_func :rl_UpdatePhysics1, [], :void
  ffi_func :rl_ResetPhysics, [], :void
  ffi_func :rl_ClosePhysics, [], :void
  ffi_func :rl_SetPhysicsGravity, %i[float float], :void
  ffi_func :rl_SetPhysicsTimeStep, [:double], :void
  ffi_func :rl_CreatePhysicsBodyCircle, %i[float float float float], :ptr
  ffi_func :rl_CreatePhysicsBodyRectangle, %i[float float float float float], :ptr
  ffi_func :rl_CreatePhysicsBodyPolygon, %i[float float float int float], :ptr
  ffi_func :rl_DestroyPhysicsBody, [:ptr], :void
  ffi_func :rl_PhysicsAddForce, %i[ptr float float], :void
  ffi_func :rl_PhysicsAddTorque, %i[ptr float], :void
  ffi_func :rl_GetPhysicsBody, [:int], :ptr
  ffi_func :rl_GetPhysicsBodiesCount, [], :int
  ffi_func :rl_GetPhysicsShapeType, [:int], :int
  ffi_func :rl_GetPhysicsShapeVerticesCount, [:int], :int
  ffi_func :rl_GetPhysicsShapeVertex, %i[ptr int ptr], :void
  ffi_func :rl_PhysicsBodySetEnabled, %i[ptr int], :void
  ffi_func :rl_PhysicsBodyGetEnabled, [:ptr], :int
  ffi_func :rl_PhysicsBodyGetPosY, [:ptr], :float
  ffi_func :rl_PhysicsBodyGetPosX, [:ptr], :float

  def self.InitPhysics = Raylib.rl_InitPhysics
  def self.UpdatePhysics = Raylib.rl_UpdatePhysics1
  def self.ResetPhysics = Raylib.rl_ResetPhysics
  def self.ClosePhysics = Raylib.rl_ClosePhysics
  def self.SetPhysicsGravity(x, y) = Raylib.rl_SetPhysicsGravity(x, y)
  def self.SetPhysicsTimeStep(delta) = Raylib.rl_SetPhysicsTimeStep(delta)
  def self.CreatePhysicsBodyCircle(x, y, radius, density) = Raylib.rl_CreatePhysicsBodyCircle(x, y, radius, density)
  def self.CreatePhysicsBodyRectangle(x, y, w, h, density) = Raylib.rl_CreatePhysicsBodyRectangle(x, y, w, h, density)
  def self.CreatePhysicsBodyPolygon(x, y, radius, sides, density) = Raylib.rl_CreatePhysicsBodyPolygon(x, y, radius, sides, density)
  def self.DestroyPhysicsBody(body) = Raylib.rl_DestroyPhysicsBody(body)
  def self.PhysicsAddForce(body, x, y) = Raylib.rl_PhysicsAddForce(body, x, y)
  def self.PhysicsAddTorque(body, amount) = Raylib.rl_PhysicsAddTorque(body, amount)
  def self.GetPhysicsBody(index) = Raylib.rl_GetPhysicsBody(index)
  def self.GetPhysicsBodiesCount = Raylib.rl_GetPhysicsBodiesCount
  def self.GetPhysicsShapeType(index) = Raylib.rl_GetPhysicsShapeType(index)
  def self.GetPhysicsShapeVerticesCount(index) = Raylib.rl_GetPhysicsShapeVerticesCount(index)
  def self.GetPhysicsShapeVertex(body, vertex, out) = Raylib.rl_GetPhysicsShapeVertex(body, vertex, out)
  def self.PhysicsBodySetEnabled(body, enabled) = Raylib.rl_PhysicsBodySetEnabled(body, enabled)
  def self.PhysicsBodyGetEnabled(body) = Raylib.rl_PhysicsBodyGetEnabled(body)
  def self.PhysicsBodyGetPosY(body) = Raylib.rl_PhysicsBodyGetPosY(body)
  def self.PhysicsBodyGetPosX(body) = Raylib.rl_PhysicsBodyGetPosX(body)

  PHYSICS_CIRCLE = 0
  PHYSICS_POLYGON = 1

    # ====== generated: wrappers + constants ======
    def self.PhysicsShatter(body, position, force)
      Raylib.rl_PhysicsShatter(body, position, force)
    end
    def self.SetPhysicsBodyRotation(body, radians)
      Raylib.rl_SetPhysicsBodyRotation(body, radians)
    end
    PHYSAC_MAX_BODIES = 64
    PHYSAC_MAX_MANIFOLDS = 4096
    PHYSAC_MAX_VERTICES = 24
    PHYSAC_DEFAULT_CIRCLE_VERTICES = 24
    PHYSAC_COLLISION_ITERATIONS = 100
    PHYSAC_PENETRATION_ALLOWANCE = 0.05
    PHYSAC_PENETRATION_CORRECTION = 0.4
    PHYSAC_PI = 3.141592653589793
end
