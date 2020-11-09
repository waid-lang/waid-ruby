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

builtin_input = Proc.new do
  input = gets
  next WaidString.new(input.chomp)
end

builtin_length = Proc.new do |str|
  if str.is_a?(WaidString)
    next WaidInteger.new(str.Value.length)
  end
  next WaidNull.new
end

builtin_toStr = Proc.new do |obj|
  WaidString.new(obj.inspect.to_s)
end

builtin_toNum = Proc.new do |str|
  is_number = true if Float(str.inspect) rescue false
  if is_number
    num = str.Value.to_f
    if num % 1 == 0
      next WaidInteger.new(num.to_i)
    else
      next WaidFloat.new(str.Value.to_f)
    end
  end
  next WaidNull.new
end

$builtins = {
  "printLine" => WaidBuiltin.new(builtin_printLine),
  "print" => WaidBuiltin.new(builtin_print),
  "length" => WaidBuiltin.new(builtin_length),
  "input" => WaidBuiltin.new(builtin_input),
  "toNum" => WaidBuiltin.new(builtin_toNum),
  "toStr" => WaidBuiltin.new(builtin_toStr)
}
