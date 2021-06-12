require_relative '../ffi'
require_relative '../waid_object'

printLine = Proc.new do |ob|
  ob = getParam(ob)
  puts ob.inspect

  returnValue
end

print = Proc.new do |ob|
  ob = getParam(ob)
  print ob.inspect

  returnValue
end

input = Proc.new do
  input = gets

  returnValue(WaidString.new(input.chomp))
end

$MODULE = WaidForeignModule.new(__FILE__)
$MODULE.define_primitive("printLine", WaidForeignFunction.new(printLine, 1))
$MODULE.define_primitive("print", WaidForeignFunction.new(print, 1))
$MODULE.define_primitive("input", WaidForeignFunction.new(input, 0))
