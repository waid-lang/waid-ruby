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

class WaidForeignInstanceFunction < WaidObject
  attr_accessor :Function, :Arity
  def initialize(prim, args)
     @Function = prim
     @Arity = args
  end

  def call(sf, *args)
    @Function.call(sf, *args)
  end

  def type
    "Function"
  end

  def inspect
    "<WaidFunction>"
  end
end


class WaidForeignRecord < WaidObject
  attr_accessor :TypeName, :Env
  def initialize(tn=nil, sf=nil)
     @TypeName = tn
     @Env = sf
  end

  def type
    "Record"
  end

  def inspect
    "<Record>"
  end
end

class WaidForeignModule < WaidObject
  attr_accessor :Identifier, :StackFrame
  def initialize(id)
    id = id.split(".")[0]
    @Identifier = id
    @StackFrame = StackFrame.new(id)
  end

  def define_primitive(name, primitive)
    @StackFrame.define(name, primitive)
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

def isNull(obj)
  obj.is_a? WaidNull
end
