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

# File I/O
file_fr = WaidForeignRecord.new("File")

file_fr.define("Path", WaidString.new(""))
file_fr.define("File_Object", WaidNull.new)

file_open = Proc.new do |rec, path, mode|
  path = getParam(path)
  mode = getParam(mode)

  if not isStr(path) or not isStr(mode)
    next returnValue

  elsif not File.exists? path.Value
    next returnValue(WaidNull.new, WaidString.new("Archivo '#{path.Value}' no existe"))
  end

  new_file = File.open(path.Value, mode: mode.Value)
  new_foreign_object = WaidForeignObject.new(new_file, "<RubyFileObject: #{path.Value}>")
  rec.define("File_Object", new_foreign_object)

  next returnValue
end
file_fr.define("open", WaidForeignInstanceFunction.new(file_open, 2))

file_read = Proc.new do |rec|
  fo = fo.getName("File_Object")
  if isNull(fo)
    next returnValue
  end

  returnValue(fo.RubyObject.read)
end
file_fr.define("read", WaidForeignInstanceFunction.new(file_read, 0))

file_close = Proc.new do |rec|
  fo = rec.getName("File_Object")
  fo.RubyObject.close

  rec.define("File_Object", WaidNull.new)
  returnValue
end
file_fr.define("close", WaidForeignInstanceFunction.new(file_close, 0))

file_write = Proc.new do |rec, str|
  str = getParam(str)

  fo = rec.getName("File_Object")

  if not isStr(str) or isNull(fo)
    next returnValue
  end
  fo.RubyObject.write(str.Value.gsub(/\\n/, "\n"))

  returnValue(str)
end
file_fr.define("write", WaidForeignInstanceFunction.new(file_write, 1))

file_writeLine = Proc.new do |rec, str|
  str = getParam(str)

  fo = rec.getName("File_Object")

  if not isStr(str) or isNull(fo)
    next returnValue
  end

  fo.RubyObject.write(str.Value + "\n")
  returnValue(str)
end
file_fr.define("writeLine", WaidForeignInstanceFunction.new(file_writeLine, 1))

$MODULE = WaidForeignModule.new(__FILE__)
$MODULE.define_primitive("File", file_fr)
$MODULE.define_primitive("printLine", WaidForeignFunction.new(printLine, 1))
$MODULE.define_primitive("print", WaidForeignFunction.new(print, 1))
$MODULE.define_primitive("input", WaidForeignFunction.new(input, 0))
