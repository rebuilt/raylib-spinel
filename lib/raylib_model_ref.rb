# frozen_string_literal: true

# ModelRef — a user-class wrapper over Raylib::Model.
#
# Why this exists: a Ruby method defined on a *native* class has no arm in a
# polymorphic dispatch, so `models.each { |model| model.material(0) }` raises
# NoMethodError when the array holds native Model views (see
# tools/repro/upstream/a_native_class_methods/). A *user class* does get arms,
# and its methods may reach the native object through a statically typed ivar.
#
# So the Model factories return this wrapper, and the helpers that take a Model
# unwrap it again with #model.
module Raylib
  class ModelRef
    def initialize(model)
      @model = model
    end

    # The underlying native view, for the helpers that hand it to C.
    def model = @model

    # The delegating surface: Ruby methods the library defines on Model, which
    # resolve here through the typed @model ivar. Add to this as code needs it.
    def material(index = 0) = @model.material(index)
    def mesh(index = 0) = @model.mesh(index)
    def material_count = @model.material_count
    def transform = @model.transform
  end
end
