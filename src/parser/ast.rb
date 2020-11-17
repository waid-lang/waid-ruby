# PORFAVORNOMEFUNENPORUSARVARIABLESGLOBALES
#
# Todas estas son para el pretty print del árbol sintáctico.
# No voy a comentar mucho las funciones "print_tree" de cada nodo porque:
# 1) Son muy enredadas
# 2) Están 100% listas y no creo que necesiten mejoras
#
# Si tú, lector, quieres darte la lata de entender el print_tree y mejorarlo,
# bienvenido seas, pero no creo que valga la pena.
$AST_INDENTATION = 4
$AST_LAST = "└" + "─" * ($AST_INDENTATION - 1)
$AST_MIDDLE = "├" + "─" * ($AST_INDENTATION - 1)
$AST_LINE = "│" + " " * ($AST_INDENTATION - 1)
$AST_SPACE = " " * $AST_INDENTATION

# Esto también es parte del pretty print
def indentation(last)
  if last
    print $AST_LAST
    return $AST_SPACE
  else
    print $AST_MIDDLE
    return $AST_LINE
  end
end

# El nodo programa es la raiz del árbol sintáctico. Consiste de un arreglo de
# Nodos de estamentos.
class Program
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

# Correponde a un nodo de un arreglo de Nodos de estamentos. Lo podría poner en
# Programa, pero por alguna razón no lo he hecho. Si quieres hacerlo y hacer un
# pull request, genial, te compro un juguito.
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

# Nodo correspondiente al estamento return de una función.
# En el código se vería algo así:
#
# Corresponde a un ReturnValue que es un nodo representando una expresión de
# algún tipo.
# Por ejemplo:
#   <- x + y
#      ~~+~~
#        +-----> @ReturnValue
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

# Representa una declaración de variable en el código fuente.
# Guarda el nombre del identificador y el arbol de una expresión como valor
# asignado.
#
# Por ejemplo
# var_name => 5
#
# var_name24 => var_name * 2 - 3
# ~~~~~+~~~~    ~~~~~~~~+~~~~~~~
#      |                +----------> @Value
#      +---------------------------> @Identifier
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


# Este nodo representa la asignación de un valor a un elemento de un arreglo.
# En el código fuente esto es:
# (expr @ arreglo) => expr
#
# Por ejemplo:
# (2 @ array) => 2 * 3 - 3
#
# ((i - 1) @ array) => i * 2
#  ~~~+~~~   ~~+~~     ~~+~~
#     |        |         +--------> @Value
#     |        +------------------> @ArrayIdentifier
#     +---------------------------> @IndexExpression 
class ArrayIndexDeclarationStatement
  attr_accessor :IndexExpression
  attr_accessor :Value
  attr_accessor :ArrayIdentifier
  def initialize(ind=nil, name=nil, val=nil)
    @IndexExpression = ind
    @ArrayIdentifier = name
    @Value = val
  end

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "ArrayIndexDeclaration"
    puts indent + $AST_MIDDLE + "IndexExpression"
    @IndexExpression.print_tree(indent + $AST_LINE, true)

    puts indent + $AST_MIDDLE + "ArrayIdentifier"
    @ArrayIdentifier.print_tree(indent + $AST_LINE, true)

    puts indent + $AST_LAST + "Value"
    @Value.print_tree(indent + $AST_SPACE, true)
  end
end


# Este nodo representa la declaración de una función.
#
# Ejemplo:
#
#  +----------------------> @Identifier
#  |          +-----------> @Parameters
# ~+~       ~~+~~
# max: func(x, y) =>
#     if x > y:      |
#         <- x       |
#     endif          +----> @Body
#     <- y           |
# endfn
#
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

# Representa el llamado de una función.
#
# Ejemplos:
#
# Sin argumentos.
#
# !printLine
#  ~~~~+~~~~
#      +---------> @Function
#
# Con argumentos.
# !(max 3 350)
#   ~+~ ~~+~~
#    |    +------> @Arguments
#    +-----------> @Function
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

# Representa una hoja vacía. Puede ser un Body de una función vació o un return
# sin nada, por ejemplo.
class Empty
  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "None"
  end
end


# Representa un estamento if-else
# Ejemplo:
#           +----------------------> @Condition
#    ~~~~~~~+~~~~~~~~
# if var - 2 > ruedas:
#     !(printLine "mal ahí") +-----> @Body
# else:
#     <- x * 2 +-------------------> @ElseBody
# endif
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

# Representa un bucle While.
# Ejemplo:
# 
#          +--------------> @Condition
#       ~~~+~~~
# while x < 150:
#     !(printLine x) |
#     a => x         +----> @Body
#     x => x + 1     |
# endwl
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

# Este nodo representa un identificador. Es una hoja en el AST.
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

# Representa una operación binaria.
#
# Ejemplo compuesto:
#
#          +-----------> @Right
#          | +---------> @Operator
#          | | +-------> @Right
# valor => 2 * a - 3
#          ~~+~~ | +---> @Right
#            |   +-----> @Operator
#            +---------> @Left
#
# Esto puesto como un árbol:
#               -
#             /   \
#           *      3
#         /   \
#        2     a
class BinaryOperatorExpression
  attr_accessor :Left, :Operator, :Right
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


# Representa un operador unario. No tiene mucha más explicación, pero acá hay
# unos ejemplos:
#          +-----------> @Operator
# valor => -(i * k)
#           ~~~+~~~
#              +-------> @Expression
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


# De aquí para abajo son puras hojas del árbol. Son todos literales y creo que
# se explican solos
##############################################################################

# Una hoja del árbol. Representa un literal entero (2, 6, 32329, 0,-4)
class IntLiteral
  attr_accessor :Value
  def initialize(val=nil)
    @Value = val.to_i
  end

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "IntLiteral"
    puts indent + $AST_LAST + @Value.to_s
  end
end

# Representa un literal de un arreglo. Guarda internamente en un arreglo todos
# los elementos del literal.
class ArrayLiteral
  attr_accessor :Values
  def initialize
    @Values = Array.new
  end

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "ArrayLiteral"
    if @Values.empty?
      puts indent + $AST_LAST + "Empty"
      return
    end
    @Values.each_with_index do |expr, index|
      expr.print_tree(indent + $AST_SPACE, index == @Values.length - 1)
    end
  end
end

class StringLiteral
  attr_accessor :Value
  def initialize(val=nil)
    @Value = val
  end

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "StringLiteral"
    puts indent + $AST_LAST + @Value
  end
end


class FloatLiteral
  attr_accessor :Value
  def initialize(val=nil)
    @Value = val.to_f
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
    @Value = val == "true"
  end

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "BooleanLiteral"
    puts indent + $AST_LAST + @Value.to_s
  end
end

class NullLiteral
  def initialize
  end

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "NullLiteral"
    puts indent + $AST_LAST + "Null"
  end
end
