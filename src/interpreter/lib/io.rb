require_relative '../ffi'
require_relative '../waid_object'
require_relative '../enviroment'

$MODULE = WaidForeignModule.new(__FILE__)

printLine = Proc.new do |ob|
  puts ob.inspect.gsub(/\\n/, "\n").gsub!('"', '')
end

print = Proc.new do |ob|
  print ob.inspect.to_s
end

input = Proc.new do
  input = gets
  next WaidString.new(input.chomp)
end

$MODULE.define_primitive("printLine", WaidForeignFunction.new(printLine, 1))
$MODULE.define_primitive("print", WaidForeignFunction.new(print, 1))
$MODULE.define_primitive("input", WaidForeignFunction.new(input, 0))

# File I/O
file_sf = StackFrame.new("File")

file_open = Proc.new do |sf, path, mode|
  if not File.exists? path.Value
    next WaidNull.new
  end
  new_file = File.open(path.Value, mode: mode.Value)
  sf.define("File_Object", new_file)
  next WaidNull.new
end

file_read = Proc.new do |sf|
  fo = sf.getLocalName("File_Object")
  if fo.is_a? WaidNull
    next fo
  end
  next fo.read
end

file_close = Proc.new do |sf|
  fo = sf.getLocalName("File_Object")
  fo.close
  sf.define("File_Object", WaidNull.new)
  WaidNull.new
end

file_write = Proc.new do |sf, str|
  fo = sf.getLocalName("File_Object")
  if not isStr(str) or isNull(fo)
    next WaidNull.new
  end
  fo.write(str.Value.gsub(/\\n/, "\n"))
  str
end

file_writeLine = Proc.new do |sf, str|
  fo = sf.getLocalName("File_Object")
  if not isStr(str) or isNull(fo)
    next WaidNull.new
  end
  fo.write(str.Value + "\n")
  str
end



file_sf.define("Path", WaidString.new(""))
file_sf.define("File_Object", WaidNull.new)
file_sf.define("open", WaidForeignInstanceFunction.new(file_open, 2))
file_sf.define("read", WaidForeignInstanceFunction.new(file_read, 0))
file_sf.define("close", WaidForeignInstanceFunction.new(file_close, 0))
file_sf.define("write", WaidForeignInstanceFunction.new(file_write, 1))
file_sf.define("writeLine", WaidForeignInstanceFunction.new(file_writeLine, 1))
file = WaidForeignRecord.new("File", file_sf)
$MODULE.define_primitive("File", file)
