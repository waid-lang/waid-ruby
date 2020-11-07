# Objetos en Waid

require_relative '../parser/ast'

# Manera chanta de implementar una clase abstracta
class WaidObject
  EX = "Error: método no implementado"

  def type; raise EX; end
  def inspect; raise EX; end
end

class WaidFunction < WaidObject
  attr_accessor :Parameters, :Body, :Env
  def initialize(p=Array.new, b= StatementList.new, e=nil)
     @Parameters = p
     @Body = b
     @Env = e
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

class WaidNull < WaidObject
  attr_accessor :Value
  def initialize
  end

  def type
    "Null"
  end

  def inspect
    "null"
  end
end

