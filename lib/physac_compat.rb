# frozen_string_literal: true

# physac compat — loaded by raylib-spinel/physac (never by the base entry).
#
# The physics shims (rl_PhysicsBodyData_*, rl_PhysicsBodySetEnabled,
# rl_DestroyPhysicsBody) only exist when lib/physac_ffi.rb is part of the
# program, so these definitions must not live in raylib_handles.rb: a scene
# that never loads physac would carry unresolved class-method calls.

module Raylib
  # The gem's PhysicsBodyData (FFI::Struct view over the opaque PhysicsBody
  # pointer). Plain Ruby: the producer returns a raw :ptr and the example wraps
  # it with PhysicsBodyData.new(ptr); consumers below accept either form.
  class PhysicsBodyData
    def initialize(ptr, owner = nil)
      @__ptr = ptr
    end

    def __ptr = @__ptr

    def id = Raylib.rl_PhysicsBodyData_id(@__ptr)
    def enabled = Raylib.rl_PhysicsBodyData_enabled(@__ptr) != 0
    def enabled=(v)
      Raylib.rl_PhysicsBodySetEnabled(@__ptr, v ? 1 : 0)
    end
    def position = Vector2.new(Raylib.rl_PhysicsBodyData_position_addr(@__ptr))
    def velocity = Vector2.new(Raylib.rl_PhysicsBodyData_velocity_addr(@__ptr))
    def force = Vector2.new(Raylib.rl_PhysicsBodyData_force_addr(@__ptr))
    def orient = Raylib.rl_PhysicsBodyData_orient(@__ptr)
    def mass = Raylib.rl_PhysicsBodyData_mass(@__ptr)
    def isGrounded = Raylib.rl_PhysicsBodyData_isGrounded(@__ptr) != 0
  end

  # Accepts a PhysicsBodyData view (the gem idiom) or the raw pointer the
  # producers return (physics_demo keeps a raw-pointer list).
  def self.DestroyPhysicsBody(body)
    if body.is_a?(PhysicsBodyData)
      Raylib.rl_DestroyPhysicsBody(body.__ptr)
    else
      Raylib.rl_DestroyPhysicsBody(body)
    end
  end
end
