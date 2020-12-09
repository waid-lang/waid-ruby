require_relative '../ffi'
require_relative '../waid_object'

sin = Proc.new do |obj|
  obj = getParam(obj)

  if not isNum(obj)
    next returnValue
  end
  returnValue(WaidFloat.new(Math.sin(obj.Value)))
end

cos = Proc.new do |obj|
  obj = getParam(obj)

  if not isNum(obj)
    next returnValue
  end
  returnValue(WaidFloat.new(Math.cos(obj.Value)))
end

sqrt = Proc.new do |obj|
  obj = getParam(obj)

  if not isNum(obj)
    next returnValue
  end
  returnValue(WaidFloat.new(Math.sqrt(obj.Value)))
end


$MODULE = WaidForeignModule.new(__FILE__)
$MODULE.define_primitive("sin", WaidForeignFunction.new(sin, 1))
$MODULE.define_primitive("cos", WaidForeignFunction.new(cos, 1))
$MODULE.define_primitive("sqrt", WaidForeignFunction.new(sqrt, 1))
