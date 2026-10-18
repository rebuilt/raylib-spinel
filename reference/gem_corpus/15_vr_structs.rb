# windowed
# VR structs: VrDeviceInfo field writers and the INLINE float arrays, which the
# gem only lets you touch element-wise (FFI::Struct#[]= on an array member
# raises NotImplementedError, measured on raylib-bindings 0.8.4). LoadVrStereoConfig
# then reads those values, so the element writes are observable through the
# config it computes. Integers only in the output: the same C floats, printed
# identically by both engines.
require "raylib"
include Raylib

Raylib.InitWindow(320, 240, "corpus-vr-structs")

device = VrDeviceInfo.new
device.hResolution = 2160
device.vResolution = 1200
device.hScreenSize = 0.133793
device.vScreenSize = 0.0669
device.eyeToScreenDistance = 0.041
device.lensSeparationDistance = 0.07
device.interpupillaryDistance = 0.07
device.lensDistortionValues[0] = 1.0
device.lensDistortionValues[1] = 0.22
device.lensDistortionValues[2] = 0.24
device.lensDistortionValues[3] = 0.0
device.chromaAbCorrection[0] = 0.996
device.chromaAbCorrection[1] = -0.004
device.chromaAbCorrection[2] = 1.014
device.chromaAbCorrection[3] = 0.0

puts "device: #{device.hResolution}x#{device.vResolution} " \
     "sep=#{(device.lensSeparationDistance * 1000).round} " \
     "ipd=#{(device.interpupillaryDistance * 1000).round}"
lens = device.lensDistortionValues
chroma = device.chromaAbCorrection
puts "lens: #{(lens[0] * 1000).round}.#{(lens[1] * 1000).round}." \
     "#{(lens[2] * 1000).round}.#{(lens[3] * 1000).round}"
puts "chroma: #{(chroma[0] * 1000).round}.#{(chroma[1] * 1000).round}." \
     "#{(chroma[2] * 1000).round}.#{(chroma[3] * 1000).round}"
# element writes must land inside their own array (a wrong byte stride shows up
# here as the other array changing)
chroma[1] = -0.008
puts "chroma re-read: #{(chroma[0] * 1000).round} #{(chroma[1] * 1000).round} " \
     "#{(lens[1] * 1000).round}"

config = LoadVrStereoConfig(device)
puts "scale: #{(config.scale[0] * 10000).round} #{(config.scale[1] * 10000).round}"
puts "scaleIn: #{(config.scaleIn[0] * 10000).round} #{(config.scaleIn[1] * 10000).round}"
puts "lensCenter: #{(config.leftLensCenter[0] * 100000).round} " \
     "#{(config.leftLensCenter[1] * 100000).round} " \
     "#{(config.rightLensCenter[0] * 100000).round} " \
     "#{(config.rightLensCenter[1] * 100000).round}"
puts "screenCenter: #{(config.leftScreenCenter[0] * 100000).round} " \
     "#{(config.rightScreenCenter[0] * 100000).round}"

# the config is passed back by value; a second load (the scene reloads on every
# IPD change) must agree with the first
other = LoadVrStereoConfig(device)
puts "reload agrees: #{(other.scale[0] * 10000).round == (config.scale[0] * 10000).round}"

UnloadVrStereoConfig(config)
UnloadVrStereoConfig(other)
Raylib.CloseWindow
