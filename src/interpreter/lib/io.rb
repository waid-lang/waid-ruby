require_relative '../ffi'
require_relative '../waid_object'

printLine = Proc.new do |ob|
  puts ob.inspect
end

print = Proc.new do |ob|
  print ob.inspect
end

input = Proc.new do
  input = gets
  next WaidString.new(input.chomp)
end


$MODULE = WaidForeignModule.new(__FILE__)
$MODULE.define_primitive("printLine", printLine, 1)
$MODULE.define_primitive("print", print, 1)
$MODULE.define_primitive("input", input, 0)
