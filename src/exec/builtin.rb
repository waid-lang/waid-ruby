require_relative 'object'

builtin_print = Proc.new do |ob|
  puts ob.inspect
end

builtin_input = Proc.new do |ob, end_char|
end

$builtins = {
  "print" => WaidBuiltin.new(builtin_print),
  "input" => WaidBuiltin.new(builtin_input)
}
