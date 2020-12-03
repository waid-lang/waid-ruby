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
#   +  ~~+~~
#   |    +-----> @ReturnValue
#   +----------> @Token
class ReturnStatement
  attr_accessor :Token, :ReturnValue
  def initialize
    @Token = nil
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
#            +---------------------> @Token
#            +
# var_name24 => var_name * 2 - 3
# ~~~~~+~~~~    ~~~~~~~~+~~~~~~~
#      |                +----------> @Value
#      +---------------------------> @Left
#
#
#                   +-------------> @Token
#                   +
# ((i - 1) @ array) => i * 2
#  ~~~~~~~~+~~~~~~~     ~~+~~
#          |              +--------> @Value
#          +-----------------------> @Left = IndexAccessExpression
class VarDeclarationStatement
  attr_accessor :Left
  attr_accessor :Value
  attr_accessor :Token
  def initialize(l=nil, val=nil)
    @Token = nil
    @Left = l
    @Value = val
  end

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "VariableDeclaration"
    puts indent + $AST_MIDDLE + "Left"
    @Left.print_tree(indent + $AST_LINE, true)

    puts indent + $AST_LAST + "Value"
    @Value.print_tree(indent + $AST_SPACE, true)
  end
end


# Este nodo representa la asignación de un valor a un elemento de un arreglo.
# En el código fuente esto es:
# (expr @ arreglo) => expr
#
# Por ejemplo:
#
# (2 @ array) => 2 * 3 - 3
#
# ((i - 1) @ array)
#     |        |
#     |        +------------------> @ArrayIdentifier
#     +---------------------------> @IndexExpression 
class IndexAccessExpression
  attr_accessor :Token, :IndexExpression, :ArrayIdentifier
  def initialize(ind=nil, name=nil, val=nil)
    @Token = nil
    @IndexExpression = ind
    @ArrayIdentifier = name
  end

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "IndexAccessExpression"
    puts indent + $AST_MIDDLE + "IndexExpression"
    @IndexExpression.print_tree(indent + $AST_LINE, true)

    puts indent + $AST_LAST + "ArrayIdentifier"
    @ArrayIdentifier.print_tree(indent + $AST_SPACE, true)
  end
end


# Este nodo representa la declaración de una función.
#
# Ejemplo:
#
#  +----------------------> @Identifier
#  |    +-----------------> @Token
#  |    |     +-----------> @Parameters
# ~+~  ~+~~ ~~+~~
# max: func(x, y) =>
#     if x > y:      |
#         <- x       |
#     endif          +----> @Body
#     <- y           |
# endfn
#
class FuncDeclarationStatement
  attr_accessor :Token, :Identifier, :Parameters, :Body
  def initialize
    @Token = nil
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

# Nodo que representa la delcaración de un nuevo record.
# Ejemplo:
#
#    +----------------------> @Identifier
#    |        +-------------> @Token
# ~~~+~~~  ~~~+~~
# Persona: record =>
#     nombre => ""     |
#     edad = 0         +----> @VariableDeclarations
#     cant_brazos => 2 |
# endrc
class RecordDeclarationStatement
  attr_accessor :Token, :Identifier, :VariableDeclarations, :InstanceFunctionDeclarations
  def initialize
    @Token = nil
    @Identifier = nil
    @VariableDeclarations = Array.new
    @InstanceFunctionDeclarations = Array.new
  end

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "RecordDeclaration"
    puts indent + $AST_MIDDLE + "Identifier"
    @Identifier.print_tree(indent + $AST_LINE, true)

    puts indent + $AST_MIDDLE + "VariableDeclarations"
    @VariableDeclarations.each_with_index do |decl, index|
      decl.print_tree(indent + $AST_LINE, index == @VariableDeclarations.length - 1)
    end
    puts indent + $AST_LAST + "InstanceFunctionDeclarations"
    @InstanceFunctionDeclarations.each_with_index do |decl, index|
      decl.print_tree(indent + $AST_SPACE, index == @InstanceFunctionDeclarations.length - 1)
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
# +--------------> @Token
# +
# !(max 3 350)
#   ~+~ ~~+~~
#    |    +------> @Arguments
#    +-----------> @Function
class FunctionCall
  attr_accessor :Token, :Function, :Arguments
  def initialize(f=nil, a=Array.new)
    @Token = nil
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

# Este nodo representa la inicialización de un record.
# Ejemplos:
#
# Sin argumentos (Se inicializa con valores default).
#
# v => !Vector
#       ~~+~~~
#         +--------> @Identifier
#
# Con argumentos.
#       +------------------------> @Token
#       +
# v2 => !{Vector "Fuerza" 2 67}
#         ~~+~~~ ~~~~~~+~~~~~~
#           |          +---------> @Identifier
#           +--------------------> @Arguments
class RecordInitialize
  attr_accessor :Token, :Identifier, :Arguments
  def initialize
    @Token = nil
    @Identifier = nil
    @Arguments = Array.new
  end

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "RecordInitialize"
    puts indent + $AST_MIDDLE + "Identifier"
    @Identifier.print_tree(indent + $AST_LINE, true)

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
#
# +--------------------------------> @Token
# |         +----------------------> @Condition
# +  ~~~~~~~+~~~~~~~~
# if var - 2 > ruedas:
#     !(printLine "mal ahí") +-----> @Body
# else:
#     <- x * 2 +-------------------> @ElseBody
# endif
class IfStatement
  attr_accessor :Token, :Condition, :Body, :ElseBody
  def initialize
    @Token = nil
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
#   +---------------------> @Token
#   |      +--------------> @Condition
# ~~+~~ ~~~+~~~
# while x < 150:
#     !(printLine x) |
#     a => x         +----> @Body
#     x => x + 1     |
# endwl
#
#   +-------------------------> @Token
#   |      +------------------> @Condition
#   |      |         +--------> @PostExpression
# ~~+~  ~~~+~~  ~~~~~+~~~~
# while i < 10, i => i + 1:
#     !(printLine i)       +--> @Body
# endwl
class WhileStatement
  attr_accessor :Token, :Condition, :PostExpression, :Body
  def initialize
    @Token = nil
    @Condition = nil
    @PostExpression = nil
    @Body = nil
  end

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "WhileStatement"
    puts indent + $AST_MIDDLE + "Condition"
    @Condition.print_tree(indent + $AST_LINE, true)

    puts indent + $AST_MIDDLE + "PostExpression"
    @PostExpression.print_tree(indent + $AST_LINE, true)

    puts indent + $AST_LAST + "Body"
    @Body.Statements.each_with_index do |stmt, index|
      stmt.print_tree(indent + $AST_SPACE, index == @Body.Statements.length - 1)
    end
  end
end

# Representa un include en el programa.
# Ejemplo:
#
# include "strings"
# ~~~+~~~     +----------> @Path
#    +-------------------> @Token

class IncludeStatement
  attr_accessor :Token, :Path
  def initialize
    @Token = nil
    @Path = nil
  end

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "IncludeStatement"

    puts indent + $AST_LAST + "Path"
    @Path.print_tree(indent + $AST_SPACE, true)
  end
end

# Este nodo representa un identificador. Es una hoja en el AST.
class Identifier
  attr_accessor :Value, :Token
  def initialize(value, tok)
    
    # El token IDENTIFIER
    @Token = tok

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
#          | +---------> @Operator/@Token
#          | | +-------> @Right
# valor => 2 * a - 3
#          ~~+~~ | +---> @Right
#            |   +-----> @Operator/@Token
#            +---------> @Left
#
# Esto puesto como un árbol:
#               -
#             /   \
#           *      3
#         /   \
#        2     a
class BinaryOperatorExpression
  attr_accessor :Token, :Left, :Operator, :Right
  def initialize(l, o, r)
    @Token = o # El token del operador: TokenKind::OP_*
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

# Representa el acceso al atributo de un record.
# Ejemplo compuesto:
#
#              +----------------------> @Object
#              |   +------------------> @Token
#              |   |    +-------------> @Attribute
#           ~~~+~~~+~~~~+~~~
# pos_x => (Vector1'posicion)'x
#          ~~~~~~~~~+~~~~~~~ ++-------> @Attribute
#                   |        +--------> @Token
#                   +-----------------> @Object
class AttributeAccessExpression
  attr_accessor :Token, :Object, :Attribute
  def initialize(o, a)
    @Token = nil
    @Object = o
    @Attribute = a
  end

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "AttributeAccess"
    puts indent + $AST_MIDDLE + "Object"
    @Object.print_tree(indent + $AST_LINE, true)

    puts indent + $AST_LAST + "Attribute"
    @Attribute.print_tree(indent + $AST_SPACE, true)
  end
end 

# Representa el acceso a un objecto en un módulo
# Ejemplo:
#
# pow_2 => !(math::pow 2 10)
#          ~+~ +  +------------> @Object
#           |  +---------------> @Token
#           +------------------> @Module
class ModuleAccessExpression
  attr_accessor :Token, :Module, :Object
  def initialize(o, a)
    @Token = nil
    @Module = o
    @Object = a
  end

  def print_tree(indent, last)
    print indent
    indent += indentation(last)

    puts "ModuleAccess"
    puts indent + $AST_MIDDLE + "Module"
    @Module.print_tree(indent + $AST_LINE, true)

    puts indent + $AST_LAST + "Object"
    @Object.print_tree(indent + $AST_SPACE, true)
  end
end 

# Representa un operador unario. No tiene mucha más explicación, pero acá hay
# unos ejemplos:
#          +-----------> @Operator/@Token
#          +
# valor => -(i * k)
#           ~~~+~~~
#              +-------> @Expression
class UnaryOperatorExpression
  attr_accessor :Operator, :Expression
  def initialize(op=nil, exp=nil)
    @Token = nil
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
