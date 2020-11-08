require_relative 'object'

builtin_printLine = Proc.new do |ob|
  if not ob
    ob = WaidString.new("\n")
  end
  puts ob.inspect
end

builtin_print = Proc.new do |ob|
  print ob.inspect
end

builtin_length = Proc.new do |str|
  if str.is_a?(WaidString)
    next WaidInteger.new(str.Value.length)
  end
  next WaidNull.new
end

builtin_input = Proc.new do |ob, end_char|
end

$builtins = {
  "printLine" => WaidBuiltin.new(builtin_printLine),
  "print" => WaidBuiltin.new(builtin_print),
  "length" => WaidBuiltin.new(builtin_length),
  "input" => WaidBuiltin.new(builtin_input)
}
