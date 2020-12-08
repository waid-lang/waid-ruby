require_relative '../ffi'
require_relative '../waid_object'

sin = Proc.new do |obj|
  if not isNum(obj)
    next WaidNull.new
  end
  WaidReturnTuple.new(WaidFloat.new(Math.sin(obj.Value)), WaidNull.new)
end

cos = Proc.new do |obj|
  if not isNum(obj)
    next WaidNull.new
  end
  WaidReturnTuple.new(WaidFloat.new(Math.cos(obj.Value)), WaidNull.new)
end

$MODULE = WaidForeignModule.new(__FILE__)
$MODULE.define_primitive("sin", sin, 1)
$MODULE.define_primitive("cos", cos, 1)
