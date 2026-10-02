# physac_ffi.rb — physac bindings for Spinel AOT.
#
# physac is compiled into lib/physac_adapter.o + lib/physac_impl.o and linked
# into the physics scene. PhysicsBody is an opaque pointer; body creation takes
# raw floats (Vector2 by value). Loaded by `require "raylib-spinel/physac"`.
# Under CRuby the raylib-bindings gem already binds physac.

module Raylib
  ffi_lib "raylib"
  ffi_cflags "-I/usr/local/include"

  ffi_func :sp_InitPhysics, [], :ptr
  ffi_func :sp_UpdatePhysics1, [], :void
  ffi_func :sp_ResetPhysics, [], :void
  ffi_func :sp_ClosePhysics, [], :void
  ffi_func :sp_SetPhysicsGravity, %i[float float], :void
  ffi_func :sp_SetPhysicsTimeStep, [:double], :void
  ffi_func :sp_CreatePhysicsBodyCircle, %i[float float float float], :ptr
  ffi_func :sp_CreatePhysicsBodyRectangle, %i[float float float float float], :ptr
  ffi_func :sp_CreatePhysicsBodyPolygon, %i[float float float int float], :ptr
  ffi_func :sp_DestroyPhysicsBody, [:ptr], :void
  ffi_func :sp_PhysicsAddForce, %i[ptr float float], :void
  ffi_func :sp_PhysicsAddTorque, %i[ptr float], :void
  ffi_func :sp_GetPhysicsBody, [:int], :ptr
  ffi_func :sp_GetPhysicsBodiesCount, [], :int
  ffi_func :sp_GetPhysicsShapeType, [:int], :int
  ffi_func :sp_GetPhysicsShapeVerticesCount, [:int], :int
  ffi_func :sp_GetPhysicsShapeVertex, %i[ptr int ptr], :void
  ffi_func :sp_PhysicsBodySetEnabled, %i[ptr int], :void
  ffi_func :sp_PhysicsBodyGetEnabled, [:ptr], :int
  ffi_func :sp_PhysicsBodyGetPosY, [:ptr], :float
  ffi_func :sp_PhysicsBodyGetPosX, [:ptr], :float

  def self.InitPhysics = Raylib.sp_InitPhysics
  def self.UpdatePhysics = Raylib.sp_UpdatePhysics1
  def self.ResetPhysics = Raylib.sp_ResetPhysics
  def self.ClosePhysics = Raylib.sp_ClosePhysics
  def self.SetPhysicsGravity(x, y) = Raylib.sp_SetPhysicsGravity(x, y)
  def self.SetPhysicsTimeStep(delta) = Raylib.sp_SetPhysicsTimeStep(delta)
  def self.CreatePhysicsBodyCircle(x, y, radius, density) = Raylib.sp_CreatePhysicsBodyCircle(x, y, radius, density)
  def self.CreatePhysicsBodyRectangle(x, y, w, h, density) = Raylib.sp_CreatePhysicsBodyRectangle(x, y, w, h, density)
  def self.CreatePhysicsBodyPolygon(x, y, radius, sides, density) = Raylib.sp_CreatePhysicsBodyPolygon(x, y, radius, sides, density)
  def self.DestroyPhysicsBody(body) = Raylib.sp_DestroyPhysicsBody(body)
  def self.PhysicsAddForce(body, x, y) = Raylib.sp_PhysicsAddForce(body, x, y)
  def self.PhysicsAddTorque(body, amount) = Raylib.sp_PhysicsAddTorque(body, amount)
  def self.GetPhysicsBody(index) = Raylib.sp_GetPhysicsBody(index)
  def self.GetPhysicsBodiesCount = Raylib.sp_GetPhysicsBodiesCount
  def self.GetPhysicsShapeType(index) = Raylib.sp_GetPhysicsShapeType(index)
  def self.GetPhysicsShapeVerticesCount(index) = Raylib.sp_GetPhysicsShapeVerticesCount(index)
  def self.GetPhysicsShapeVertex(body, vertex, out) = Raylib.sp_GetPhysicsShapeVertex(body, vertex, out)
  def self.PhysicsBodySetEnabled(body, enabled) = Raylib.sp_PhysicsBodySetEnabled(body, enabled)
  def self.PhysicsBodyGetEnabled(body) = Raylib.sp_PhysicsBodyGetEnabled(body)
  def self.PhysicsBodyGetPosY(body) = Raylib.sp_PhysicsBodyGetPosY(body)
  def self.PhysicsBodyGetPosX(body) = Raylib.sp_PhysicsBodyGetPosX(body)

  PHYSICS_CIRCLE = 0
  PHYSICS_POLYGON = 1
end
