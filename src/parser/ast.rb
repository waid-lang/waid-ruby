
def ident(level, text)
  " " * 2 * level + text
end

class Programa
  attr_accessor :Statements
  def initialize
    @Statements = Array.new
  end

  def to_string
    level = 0
    puts "AST"
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
    puts ident(level, "ReturnStatement")
    puts ident(level + 1, "ReturnValue")
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
    puts ident(level, "VariableDeclaration")
    puts ident(level + 1, "Identifier")
    @Identifier.to_string(level + 2)

    puts ident(level + 1, "Value")
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
    puts ident(level, "FunctionDeclarationStatement")
    puts ident(level + 1, "Identifier")
    @Identifier.to_string(level + 2)

    puts ident(level + 1, "Paramenters")
    @Parameters.each do |id|
      id.to_string(level + 2)
    end

    puts ident(level + 1, "Body")
    @Body.Statements.each do |stmt|
      stmt.to_string(level + 2)
    end
  end
end

IfStatement = Struct.new(
  :Condition, # Expresión
  :Body, # StatementList
  :ElseBody # StatementList
)

WhileStatement = Struct.new(
  :Condition, # Expresión
  :Body # StatementList
)

class Identifier
  attr_accessor :Value
  def initialize(value)
    @Value = value
  end

  def to_string(level)
    puts ident(level, "Identifier")
    puts ident(level + 1, @Value)
  end
end

class BinaryOperatorExpression
  def initialize(l, o, r)
    @Left = l
    @Operator = o
    @Right = r
  end

  def to_string(level)
    puts ident(level, "BinaryOperation")
    puts ident(level + 1, "Left")
    @Left.to_string(level + 2)

    puts ident(level + 1, "Operator")
    puts ident(level + 2, @Operator.to_s)

    puts ident(level + 1, "Right")
    @Right.to_string(level + 2)
  end
end 

UnaryOperatorExpression = Struct.new(
  :Operator,
  :Expression
)

class LiteralInt
  attr_accessor :Value
  def initialize
    @Value
  end

  def to_string(level)
    puts ident(level, "LiteralInt")
    puts ident(level + 1, "Value")
    puts ident(level + 2, @Value.to_s)
  end
end

