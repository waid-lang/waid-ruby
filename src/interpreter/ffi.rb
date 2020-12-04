require_relative 'waid_object'
require_relative 'enviroment'

class WaidForeignFunction < WaidObject
  attr_accessor :Function, :Arity
  def initialize(prim, args)
     @Function = prim
     @Arity = args
  end

  def type
    "Function"
  end

  def inspect
    "<WaidFunction>"
  end
end

class WaidForeignModule < WaidObject
  attr_accessor :Identifier, :StackFrame
  def initialize(id)
    id = id.split(".")[0]
    @Identifier = id
    @StackFrame = StackFrame.new(id)
  end

  def define_primitive(name, primitive, args)
    func = WaidForeignFunction.new(primitive, args)
    @StackFrame.define(name, func)
  end

  def type
    "Module"
  end

  def inspect
    "<Module: #{@Identifier}>"
  end
end

def isInt(obj)
  obj.is_a? WaidInteger
end

def isFloat(obj)
  obj.is_a? WaidFloat
end

def isNum(obj)
  isInt(obj) or isFloat(obj)
end

def isStr(obj)
  obj.is_a? WaidString
end
