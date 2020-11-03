$AST_INDENTATION = 3

def indent(level, text)
  " " * $AST_INDENTATION * (level) + text
end

class Programa
  attr_accessor :Statements
  def initialize
    @Statements = Array.new
  end

  def to_string
    level = 0
    puts "Program"
    @Statements.each do |stmt|
      stmt.to_string(level + 1)
    end
  end
end

class StatementList
  attr_accessor :Statements
  def initialize
    @Statements = Array.new
  end

  def push(elem)
    @Statements.push(elem)
  end
end

class ReturnStatement
  attr_accessor :ReturnValue
  def initialize
    @ReturnValue = nil
  end

  def to_string(level)
    puts indent(level, "ReturnStatement")
    puts indent(level + 1, "ReturnValue")
    @ReturnValue.to_string(level + 2)
  end
end

class VarDeclarationStatement
  attr_accessor :Identifier
  attr_accessor :Value
  def initialize(id=nil, val=nil)
    @Identifier = id
    @Value = val
  end

  def to_string(level)
    puts indent(level, "VariableDeclaration")
    puts indent(level + 1, "Identifier")
    @Identifier.to_string(level + 2)

    puts indent(level + 1, "Value")
    @Value.to_string(level + 2)
  end
end

class FuncDeclarationStatement
  attr_accessor :Identifier
  attr_accessor :Parameters
  attr_accessor :Body
  def initialize
    @Identifier = nil
    @Parameters = Array.new
    @Body = nil
  end

  def to_string(level)
    puts indent(level, "FunctionDeclarationStatement")
    puts indent(level + 1, "Identifier")
    @Identifier.to_string(level + 2)

    puts indent(level + 1, "Paramenters")
    @Parameters.each do |id|
      id.to_string(level + 2)
    end

    puts indent(level + 1, "Body")
    @Body.Statements.each do |stmt|
      stmt.to_string(level + 2)
    end
  end
end

class FunctionCall
  attr_accessor :Function, :Arguments
  def initialize(f=nil, a=Array.new)
    @Function = f
    @Arguments = a
  end

  def to_string(level)
    puts indent(level, "FunctionCall")
    puts indent(level + 1, "FunctionName")
    @Function.to_string(level + 2)

    puts indent(level + 1, "Arguments")
    @Arguments.each do |arg|
      arg.to_string(level + 2)
    end
  end
end

class Empty
  def to_string(level)
    puts indent(level, "Empty")
  end
end

IfStatement = Struct.new(
  :Condition, # Expresión
  :Body, # StatementList
  :ElseBody # StatementList
)
class IfStatement
  attr_accessor :Condition, :Body, :ElseBody
  def initialize
    @Condition = nil
    @Body = nil
    @ElseBody = nil
  end

  def to_string(level)
    puts indent(level, "IfStatement")
    puts indent(level + 1, "Condition")
    @Condition.to_string(level + 2)

    puts indent(level + 1, "Body")
    @Body.Statements.each do |stmt|
      stmt.to_string(level + 2)
    end
  end
end

class WhileStatement
  attr_accessor :Condition, :Body
  def initialize
    @Condition = nil
    @Body = nil
  end

  def to_string(level)
    puts indent(level, "WhileStatement")
    puts indent(level + 1, "Condition")
    @Condition.to_string(level + 2)

    puts indent(level + 1, "Body")
    @Body.Statements.each do |stmt|
      stmt.to_string(level + 2)
    end
  end
end

class Identifier
  attr_accessor :Value
  def initialize(value)
    @Value = value
  end

  def to_string(level)
    puts indent(level, "Identifier")
    puts indent(level + 1, @Value)
  end
end

class BinaryOperatorExpression
  def initialize(l, o, r)
    @Left = l
    @Operator = o
    @Right = r
  end

  def to_string(level)
    puts indent(level, "BinaryOperation")
    puts indent(level + 1, "Left")
    @Left.to_string(level + 2)

    puts indent(level + 1, "Operator")
    puts indent(level + 2, @Operator.to_s)

    puts indent(level + 1, "Right")
    @Right.to_string(level + 2)
  end
end 

UnaryOperatorExpression = Struct.new(
  :Operator,
  :Expression
)

class LiteralInt
  attr_accessor :Value
  def initialize(val=nil)
    @Value = val
  end

  def to_string(level)
    puts indent(level, "LiteralInt")
    puts indent(level + 1, @Value.to_s)
  end
end

