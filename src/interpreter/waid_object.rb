# Objetos en Waid

require_relative '../parser/ast'

# Manera chanta de implementar una clase abstracta
class WaidObject
  EX = "Error: método no implementado"

  def type; raise EX; end
  def inspect; raise EX; end
end

class WaidFunction < WaidObject
  attr_accessor :Parameters, :Body, :Env, :Arity
  def initialize(p=Array.new, b=StatementList.new, a=nil)
     @Parameters = p
     @Body = b
     @Arity = a
  end

  def type
    "Function"
  end

  def inspect
    s = "<WaidFunction("
    @Parameters.each_with_index do |id, index|
      s += id.Value
      if @Parameters.length - 1 != index
        s += ", "
      end
    end
    s + ")>"
  end
end

# Todas las funciones en Waid retornan una tupla (valor, error).
# El primer elemento solo es accesible cuando el valor de la función es
# asignado a una variable. Por ejemplo:
# 
# res => !(add 2 4)
#
# !(printLine !(add 2 9))
#
# Por otro lado, el segundo elemento de la tupla solo es accesible mediante el
# operador "~>". Por ejemplo:
#
# res => !(divide num1 num2)~> div_error
class WaidReturnTuple < WaidObject
  attr_accessor :Value, :Error
  def initialize(first=nil, second=nil)
     @Value = first
     @Error = second
  end

  def type
    "ReturnTuple"
  end

  def inspect
    "ReturnTuple"
  end
end

class WaidBuiltin < WaidObject
  attr_accessor :Function, :Arity
  def initialize(fn=nil, ar=0)
    @Function = fn
    @Arity = ar
  end
  
  def type
    "Builtin"
  end

  def inspect
    "Builtin function"
  end
end

class WaidInteger < WaidObject
  attr_accessor :Value
  def initialize(val=nil)
    @Value = val
  end

  def type
    "Integer"
  end

  def inspect
    @Value.to_s
  end
end

class WaidString < WaidObject
  attr_accessor :Value
  def initialize(val=nil)
    @Value = val
  end

  def type
    "String"
  end

  def inspect
    @Value
  end
end


class WaidFloat < WaidObject
  attr_accessor :Value
  def initialize(val=nil)
    @Value = val
  end

  def type
    "Float"
  end

  def inspect
    @Value.to_s
  end
end

class WaidBoolean < WaidObject
  attr_accessor :Value
  def initialize(val=nil)
    @Value = val
  end

  def type
    "Boolean"
  end

  def inspect
    @Value.to_s
  end
end

class WaidArray < WaidObject
  attr_accessor :Values
  def initialize(val=Array.new)
    @Values = val
  end

  def type
    "Array"
  end

  def inspect
    str = "["
    @Values.each_with_index do |val, index|
      if val.is_a?(WaidString)
        str += '"' + val.inspect + '"'
      else
        str += val.inspect
      end
      if index != @Values.length - 1
        str += ", "
      end
    end
    str += "]"
    str
  end
end

class WaidModule < WaidObject
  attr_accessor :Identifier, :StackFrame
  def initialize(id, sf)
    @Identifier = id
    @StackFrame = sf
  end

  def type
    "Module"
  end

  def inspect
    "<Module: #{@Identifier}>"
  end
end

class WaidRecord < WaidObject
  attr_accessor :TypeName, :Env
  def initialize(env)
    @TypeName = nil
    @Env = env
  end

  def type
    "Record"
  end

  def inspect
    str = "<Record("
    @Env.getAllNames.each do |id, val|
      str += "#{id}"
      str += ", "
    end
    str = str[0...-2]
    str += ")>"
    str
  end
end

class WaidRecordInstance < WaidObject
  attr_accessor :Identifier, :Env
  def initialize
    @Identifier = nil
    @Env = nil
  end

  def type
    "<Instance of: #{@Identifier.Value}>"
  end

  def inspect
    "<Instance of: #{@Identifier.Value}>"
  end
end


class WaidNull < WaidObject
  attr_accessor :Value
  def initialize
    @Value = nil
  end

  def type
    "Null"
  end

  def inspect
    "null"
  end
end
