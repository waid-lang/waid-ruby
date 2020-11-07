$AST_INDENTATION = 4
$AST_LAST = "└" + "─" * ($AST_INDENTATION - 1)
$AST_MIDDLE = "├" + "─" * ($AST_INDENTATION - 1)
$AST_LINE = "│" + " " * ($AST_INDENTATION - 1)
$AST_SPACE = " " * $AST_INDENTATION

def indentation(last)
  if last
    print $AST_LAST
    return $AST_SPACE
  else
    print $AST_MIDDLE
    return $AST_LINE
  end
end

class Programa
  attr_accessor :Statements
  def initialize
    @Statements = Array.new
  end

  def print_tree(indent, last)
    puts "Program"
    @Statements.each_with_index do |stmt, index|
      stmt.print_tree(indent, index == @Statements.length - 1)
    end
  end
end

class StatementList
  attr_accessor :Statements
  def initialize
    @Statements = Array.new
  end

  def empty?
    @Statements.empty?
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

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "ReturnStatement"
    @ReturnValue.print_tree(indent, true)
  end
end

class VarDeclarationStatement
  attr_accessor :Identifier
  attr_accessor :Value
  def initialize(id=nil, val=nil)
    @Identifier = id
    @Value = val
  end

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "VariableDeclaration"
    puts indent + $AST_MIDDLE + "Identifier"
    @Identifier.print_tree(indent + $AST_LINE, true)

    puts indent + $AST_LAST + "Value"
    @Value.print_tree(indent + $AST_SPACE, true)
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

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "FuncDecl"
    puts indent + $AST_MIDDLE + "Identifier"
    @Identifier.print_tree(indent + $AST_LINE, true)

    puts indent + $AST_MIDDLE + "Parameters"
    @Parameters.each_with_index do |id, index|
      id.print_tree(indent + $AST_LINE, index == @Parameters.length - 1)
    end

    puts indent + $AST_LAST + "Body"
    @Body.Statements.each_with_index do |stmt, index|
      stmt.print_tree(indent + $AST_SPACE, index == @Body.Statements.length - 1)
    end
  end
end

class FunctionCall
  attr_accessor :Function, :Arguments
  def initialize(f=nil, a=Array.new)
    @Function = f
    @Arguments = a
  end

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "FunctionCall"
    puts indent + $AST_MIDDLE + "Identifier"
    @Function.print_tree(indent + $AST_LINE, true)

    puts indent + $AST_LAST + "Arguments"
    @Arguments.each_with_index do |stmt, index|
      stmt.print_tree(indent + $AST_SPACE, index == @Arguments.length - 1)
    end
  end
end

class Empty

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "None"
  end
end

class IfStatement
  attr_accessor :Condition, :Body, :ElseBody
  def initialize
    @Condition = nil
    @Body = nil
    @ElseBody = nil
  end

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "IfStatement"
    puts indent + $AST_MIDDLE + "Condition"
    @Condition.print_tree(indent + $AST_LINE, true)

    puts indent + $AST_MIDDLE + "Body"
    @Body.Statements.each_with_index do |stmt, index|
      stmt.print_tree(indent + $AST_LINE, index == @Body.Statements.length - 1)
    end

    puts indent + $AST_LAST + "ElseBody"
    @ElseBody.Statements.each_with_index do |stmt, index|
      stmt.print_tree(indent + $AST_SPACE, index == @ElseBody.Statements.length - 1)
    end
    if @ElseBody.empty?
      puts indent + $AST_SPACE + $AST_LAST + "Empty"
    end
  end
end

class WhileStatement
  attr_accessor :Condition, :Body
  def initialize
    @Condition = nil
    @Body = nil
  end

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "WhileStatement"
    puts indent + $AST_MIDDLE + "Condition"
    @Condition.print_tree(indent + $AST_LINE, true)

    puts indent + $AST_LAST + "Body"
    @Body.Statements.each_with_index do |stmt, index|
      stmt.print_tree(indent + $AST_SPACE, index == @Body.Statements.length - 1)
    end
  end
end

class Identifier
  attr_accessor :Value
  def initialize(value)
    @Value = value
  end

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "Identifier"
    puts indent + $AST_LAST + @Value
  end
end

class BinaryOperatorExpression
  def initialize(l, o, r)
    @Left = l
    @Operator = o
    @Right = r
  end

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "BinaryOperation"
    puts indent + $AST_MIDDLE + "Left"
    @Left.print_tree(indent + $AST_LINE, true)

    puts indent + $AST_MIDDLE + "Operator"
    puts indent + $AST_LINE + $AST_LAST + @Operator.to_s

    puts indent + $AST_LAST + "Right"
    @Right.print_tree(indent + $AST_SPACE, true)
  end
end 

class UnaryOperatorExpression
  attr_accessor :Operator, :Expression
  def initialize(op=nil, exp=nil)
    @Operator = op
    @Expression = exp
  end

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "UnaryOperation"
    puts indent + $AST_MIDDLE + "Operator"
    puts indent + $AST_LINE + $AST_LAST + @Operator.to_s

    puts indent + $AST_LAST + "Expression"
    @Expression.print_tree(indent + $AST_SPACE, true)
  end
end

class IntLiteral
  attr_accessor :Value
  def initialize(val=nil)
    @Value = val
  end

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "IntLiteral"
    puts indent + $AST_LAST + @Value.to_s
  end
end

class FloatLiteral
  attr_accessor :Value
  def initialize(val=nil)
    @Value = val
  end

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "FloatLiteral"
    puts indent + $AST_LAST + @Value.to_s
  end
end

class BooleanLiteral
  attr_accessor :Value
  def initialize(val=nil)
    @Value = val
  end

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "BooleanLiteral"
    puts indent + $AST_LAST + @Value.to_s
  end
end

