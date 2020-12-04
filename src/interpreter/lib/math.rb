require_relative '../ffi'
require_relative '../waid_object'

sin = Proc.new do |obj|
  if not isNum(obj)
    next WaidNull.new
  end
  WaidFloat.new(Math.sin(obj.Value))
end

cos = Proc.new do |obj|
  if not isNum(obj)
    next WaidNull.new
  end
  WaidFloat.new(Math.cos(obj.Value))
end

$MODULE = WaidForeignModule.new(__FILE__)
$MODULE.define_primitive("sin", sin, 1)
$MODULE.define_primitive("cos", cos, 1)
