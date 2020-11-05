$AST_INDENTATION = 3
$AST_LAST = "└" + "─" * ($AST_INDENTATION - 1)
$AST_MIDDLE = "├" + "─" * ($AST_INDENTATION - 1)
$AST_LINE = "│" + " " * ($AST_INDENTATION - 1)
$AST_SPACE = " " * $AST_INDENTATION

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

  def to_string(level)
    puts indent(level, "ReturnStatement")
    puts indent(level + 1, "ReturnValue")
    @ReturnValue.to_string(level + 2)
  end

  def print_tree(indent, last)
    print indent
    if last
      print $AST_LAST
      indent += $AST_SPACE
    else
      print $AST_MIDDLE
      indent += $AST_LINE
    end
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

  def to_string(level)
    puts indent(level, "VariableDeclaration")
    puts indent(level + 1, "Identifier")
    @Identifier.to_string(level + 2)

    puts indent(level + 1, "Value")
    @Value.to_string(level + 2)
  end

  def print_tree(indent, last)
    print indent
    if last
      print $AST_LAST
      indent += $AST_SPACE
    else
      print $AST_MIDDLE
      indent += $AST_LINE
    end
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

  def print_tree(indent, last)
    print indent
    if last
      print $AST_LAST
      indent += $AST_SPACE
    else
      print $AST_MIDDLE
      indent += $AST_LINE
    end
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

  def to_string(level)
    puts indent(level, "FunctionCall")
    puts indent(level + 1, "FunctionName")
    @Function.to_string(level + 2)

    puts indent(level + 1, "Arguments")
    @Arguments.each do |arg|
      arg.to_string(level + 2)
    end
  end

  def print_tree(indent, last)
    print indent
    if last
      print $AST_LAST
      indent += $AST_SPACE
    else
      print $AST_MIDDLE
      indent += $AST_LINE
    end
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
  def to_string(level)
    puts indent(level, "Empty")
  end

  def print_tree(indent, last)
    print indent
    if last
      print $AST_LAST
      indent += $AST_SPACE
    else
      print $AST_MIDDLE
      indent += $AST_LINE
    end
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

  def to_string(level)
    puts indent(level, "IfStatement")
    puts indent(level + 1, "Condition")
    @Condition.to_string(level + 2)

    puts indent(level + 1, "Body")
    @Body.Statements.each do |stmt|
      stmt.to_string(level + 2)
    end
  end
  def print_tree(indent, last)
    print indent
    if last
      print $AST_LAST
      indent += $AST_SPACE
    else
      print $AST_MIDDLE
      indent += $AST_LINE
    end
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

  def to_string(level)
    puts indent(level, "WhileStatement")
    puts indent(level + 1, "Condition")
    @Condition.to_string(level + 2)

    puts indent(level + 1, "Body")
    @Body.Statements.each do |stmt|
      stmt.to_string(level + 2)
    end
  end

  def print_tree(indent, last)
    print indent
    if last
      print $AST_LAST
      indent += $AST_SPACE
    else
      print $AST_MIDDLE
      indent += $AST_LINE
    end
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

  def to_string(level)
    puts indent(level, "Identifier")
    puts indent(level + 1, @Value)
  end

  def print_tree(indent, last)
    print indent
    if last
      print $AST_LAST
      indent += $AST_SPACE
    else
      print $AST_MIDDLE
      indent += $AST_LINE
    end
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

  def to_string(level)
    puts indent(level, "BinaryOperation")
    puts indent(level + 1, "Left")
    @Left.to_string(level + 2)

    puts indent(level + 1, "Operator")
    puts indent(level + 2, @Operator.to_s)

    puts indent(level + 1, "Right")
    @Right.to_string(level + 2)
  end

  def print_tree(indent, last)
    print indent
    if last
      print $AST_LAST
      indent += $AST_SPACE
    else
      print $AST_MIDDLE
      indent += $AST_LINE
    end
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
    if last
      print $AST_LAST
      indent += $AST_SPACE
    else
      print $AST_MIDDLE
      indent += $AST_LINE
    end
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

  def to_string(level)
    puts indent(level, "IntLiteral")
    puts indent(level + 1, @Value.to_s)
  end

  def print_tree(indent, last)
    print indent
    if last
      print $AST_LAST
      indent += $AST_SPACE
    else
      print $AST_MIDDLE
      indent += $AST_LINE
    end
    puts "IntLiteral"
    puts indent + $AST_LAST + @Value.to_s
  end
end

class BooleanLiteral
  attr_accessor :Value
  def initialize(val=nil)
    @Value = val
  end

  def to_string(level)
    puts indent(level, "BooleanLiteral")
    puts indent(level + 1, @Value.to_s)
  end

  def print_tree(indent, last)
    print indent
    if last
      print $AST_LAST
      indent += $AST_SPACE
    else
      print $AST_MIDDLE
      indent += $AST_LINE
    end
    puts "BooleanLiteral"
    puts indent + $AST_LAST + @Value.to_s
  end
end

