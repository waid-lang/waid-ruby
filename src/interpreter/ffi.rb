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

class WaidForeignRecord < WaidObject
  attr_accessor :TypeName, :Env
  def initialize(tn=nil)
     @TypeName = tn
     @Env = StackFrame.new(tn)
  end

  def define(name, obj)
    @Env.define(name, obj)
  end

  def getName(name)
    @Env.getLocalName(name)
  end

  def type
    "Record"
  end

  def inspect
    "<Record: #{@TypeName}>"
  end
end

class WaidForeignInstanceFunction < WaidObject
  attr_accessor :Function, :Arity
  def initialize(prim, args)
     @Function = prim
     @Arity = args
  end

  def call(this, *args)
    @Function.call(this.Env, *args)
  end

  def type
    "Function"
  end

  def inspect
    "<WaidFunction>"
  end
end

class WaidForeignObject < WaidObject
  attr_accessor :RubyObject
  def initialize(obj, repr)
    @RubyObject = obj
    @Representation = repr
  end

  def type
    @Representation
  end

  def inspect
    @Representation
  end
end
### Funciones para usar en las librerías ffi ###

def returnValue(value=WaidNull.new, error=WaidNull.new)
  WaidReturnTuple.new(value, error)
end

def getParam(obj)
  if obj.is_a? WaidReturnTuple
    return obj.Value
  end
  obj
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
