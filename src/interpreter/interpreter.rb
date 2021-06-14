require_relative '../parser/ast'
require_relative 'enviroment'
require_relative 'waid_object'
require_relative 'builtin'
require_relative 'ffi'

TrueValue = WaidBoolean.new(true)
FalseValue = WaidBoolean.new(false)
NullValue = WaidNull.new

class Interpreter
  def initialize(ast, err_coll)
    @ast = ast
    @error_collector = err_coll
    @is_module = 0

    @runtime_stack = RuntimeStack.new
  end

  def env
    @runtime_stack
  end

  def addRuntimeError(message, token)
    c_err = CompilationError.new(message, token.source_position)
    @error_collector.addError(c_err)
    @error_collector.showErrors
  end

  def inModuleContext
    @is_module != 0
  end

  # Converts a ruby boolean into a waid boolean object
  def boolToWaidBoolean(val)
    if val
      return TrueValue
    end
    FalseValue
  end

  # Convierte implicitamente un valor a un booleano
  # Por ejemplo:
  #
  # null -> false
  # "" -> false
  # [] -> false
  # Todo el resto -> true
  def isTruthy(obj)
    if obj.is_a? WaidString
      if obj.Value == ""
        return false
      end
      return true
    end
    if obj.is_a? WaidArray
      if obj.Values.length == 0
        return false
      end
      return true
    end
    if obj.is_a? WaidBoolean
      return obj.Value
    end
    if obj.is_a? WaidReturnTuple
      return isTruthy(obj.Value)
    end
    not obj.is_a? WaidNull
  end

  # Evalúa un operador unario
  def evalUnaryOperatorExpression(node, expr)
    case node.Operator.kind
    when TokenKind::OP_MINUS
      return evalMinusOperatorExpression(expr)
    when TokenKind::KEY_NOT
      if expr.is_a?(WaidString) or expr.is_a?(WaidNull) or expr.is_a?(WaidRecordInstance) or expr.is_a? WaidBoolean
        return boolToWaidBoolean(!isTruthy(expr))
      end
      return boolToWaidBoolean(!isTruthy(expr.Value))
    end
  end

  def evalMinusOperatorExpression(expr)
    case expr
    when WaidInteger
      return WaidInteger.new(-expr.Value)
    when WaidFloat
      return WaidFloat.new(-expr.Value)
    end
  end

  def evalFloatBinaryOperatorexpression(node, left, right)
    case node.Operator.kind
    when TokenKind::OP_PLUS
      return WaidFloat.new(left.Value + right.Value)
    when TokenKind::OP_MINUS
      return WaidFloat.new(left.Value - right.Value)
    when TokenKind::OP_ASTERISK
      return WaidFloat.new(left.Value * right.Value)
    when TokenKind::OP_SLASH
      if right.Value == 0
        # TODO: Implementar sistema de manejo de errores
        addRuntimeError("Division by 0", node.Token)
      end
      return WaidFloat.new(left.Value / right.Value)
    when TokenKind::OP_MODULUS
      return WaidFloat.new(left.Value % right.Value)
    when TokenKind::OP_GREATER
      return boolToWaidBoolean(left.Value > right.Value)
    when TokenKind::OP_LESS
      return boolToWaidBoolean(left.Value < right.Value)
    when TokenKind::OP_EQUAL
      return boolToWaidBoolean(left.Value == right.Value)
    end
  end

  def evalIntegerBinaryOperatorexpression(node, left, right)
    case node.Operator.kind
    when TokenKind::OP_PLUS
      return WaidInteger.new(left.Value + right.Value)
    when TokenKind::OP_MINUS
      return WaidInteger.new(left.Value - right.Value)
    when TokenKind::OP_ASTERISK
      return WaidInteger.new(left.Value * right.Value)
    when TokenKind::OP_SLASH
      if right.Value == 0
        addRuntimeError("Division by 0", node.Token)
      end
      return WaidFloat.new(left.Value.fdiv(right.Value))
    when TokenKind::OP_MODULUS
      return WaidInteger.new(left.Value % right.Value)
    when TokenKind::OP_LESS
      return boolToWaidBoolean(left.Value < right.Value)
    when TokenKind::OP_LESS_EQUAL
      return boolToWaidBoolean(left.Value <= right.Value)
    when TokenKind::OP_EQUAL
      return boolToWaidBoolean(left.Value == right.Value)
    when TokenKind::OP_NOT_EQUAL
      return boolToWaidBoolean(left.Value != right.Value)
    when TokenKind::OP_GREATER
      return boolToWaidBoolean(left.Value > right.Value)
    end
  end

  def evalBooleanBinaryOperation(node, left, right)
    case node.Operator.kind
    when TokenKind::KEY_AND
      # Esto es una optimización super penca en verdad. Con esto devolvemos el
      # valor de verdad de un "and" sin tener que verificar todos los valores,
      # esto es, apenas pillamos un false, devolvemos false
      l = isTruthy(left)
      if not l
        return FalseValue
      end
      return boolToWaidBoolean(l && isTruthy(right))
    when TokenKind::KEY_OR
      return boolToWaidBoolean(isTruthy(left) || isTruthy(right))
    end
  end

  def evalStringBinaryOperationExpression(node, left, right)
    case node.Operator.kind
    when TokenKind::OP_DOT
      return WaidString.new(left.Value + right.Value)
    when TokenKind::OP_EQUAL
      return boolToWaidBoolean(left.Value == right.Value)
    end
  end

  def evalBinaryOperatorExpression(node, left, right)
    if right.is_a? WaidReturnTuple
      right = right.Value
    end
    if left.is_a? WaidReturnTuple
      left = left.Value
    end

    operator = node
    if left.is_a? WaidInteger and right.is_a? WaidInteger
      return evalIntegerBinaryOperatorexpression(node, left, right)

    elsif left.is_a? WaidFloat and right.is_a? WaidInteger
      return evalFloatBinaryOperatorexpression(node, left, right)

    elsif left.is_a? WaidFloat and right.is_a? WaidFloat
      return evalFloatBinaryOperatorexpression(node, left, right)

    elsif left.is_a? WaidInteger and right.is_a? WaidFloat
      return evalFloatBinaryOperatorexpression(node, left, right)

    elsif left.is_a? WaidBoolean and right.is_a? WaidBoolean
      return evalBooleanBinaryOperation(node, left, right)

    elsif left.is_a? WaidString and right.is_a? WaidString
      return evalStringBinaryOperationExpression(node, left, right)

    elsif left.is_a? WaidArray and right.is_a? WaidArray
      case node.Operator.kind
      when TokenKind::OP_PLUS
        return right.Values + left.Values
      when TokenKind::OP_DOT
        left.Values.push(right)
        return left

      # Verificar igualdad de arreglos
      when TokenKind::OP_EQUAL
        val = true

        # Si no tienen el mismo largo son distintos
        if left.Values.length != right.Values.length
          val = false
        else
          left.Values.zip(right.Values).each do |l, r|

            # Si algún objeto es de distinto tipo que su par, los arreglos son
            # distintos
            if l.class != r.class
              val = false
              break
            else

              # En caso contrario, verificamos la igualdad de sus valores
              val = evalBinaryOperatorExpression(operator, l, r)
            end
          end
        end

        # Y transformamos la respuesta a un booleano de Waid
        return boolToWaidBoolean(val)
      end

    elsif left.is_a? WaidInteger and right.is_a? WaidArray and node.Operator.kind == TokenKind::OP_AT
      if left.Value >= right.Values.length
        return NullValue
      end
      return right.Values[left.Value]

    elsif left.is_a? WaidInteger and right.is_a? WaidString and node.Operator.kind == TokenKind::OP_AT
      return WaidString.new(right.Value[left.Value])

    elsif left.is_a? WaidFunction and right.is_a? WaidFunction and node.Operator.kind == TokenKind::OP_EQUAL
      return boolToWaidBoolean(left == right)

    elsif left.is_a? WaidNull and right.is_a? WaidNull and node.Operator.kind == TokenKind::OP_EQUAL
      return WaidBoolean.new(true)

    elsif left.is_a? WaidArray and node.Operator.kind == TokenKind::OP_DOT
      left.Values.push(right)
      return left
    elsif [TokenKind::KEY_AND, TokenKind::KEY_OR].include? node.Operator.kind
      return evalBooleanBinaryOperation(operator, left, right)
    else
      addRuntimeError("Type mismatch. Can not operate #{left.type} #{node.Operator} #{right.type}", node.Token)
    end
  end

  def evalWhileStatement(node)
    res = NullValue
    while isTruthy(evalNode(node.Condition))
      res = evalNode(node.Body)

      # Si estamos devolviendo algo, no seguir con el while y devolver el valor
      if @runtime_stack.isReturnState
        return res
      end
      evalNode(node.PostExpression)
    end
    res
  end

  def evalIfStatement(node)
    condition = evalNode(node.Condition)
    if isTruthy(condition)
      return evalNode(node.Body)
    elsif not node.ElseBody.Statements.empty?
      return evalNode(node.ElseBody)
    end
    return NullValue
  end

  def evalStatementList(node)
    result = NullValue
    node.Statements.each do |stmt|
      result = evalNode(stmt)

      # Si un statement es un Return, entramos en lo que llampe un ReturnState.
      # ReturnState es una bandera que tiene el interpretador para decirle a
      # otras partes del programa (if/else, while) que no ejecuten el resto de
      # su código porque se está devolviendo algo.
      if stmt.is_a? ReturnStatement
        @runtime_stack.setReturnState
      end
      if @runtime_stack.isReturnState
        return result
      end
    end
    result
  end

  # Probablemente la función más importante del interpretador. Evalúa el
  # llamado de una función.
  def evalFunctionCall(node)

    # Evaluamos los argumentos. Lo hacemos primero para que sean evaluados
    # dentro del StackFrame de donde se llamó la función.
    arguments = evalExpressions(node.Arguments)

    # Resolvemos el objeto WaidFunction
    func = evalNode(node.Function)

    # Si no es una función, tiramos error
    if not func.is_a? WaidFunction and not func.is_a? WaidBuiltin and not func.is_a? WaidForeignFunction and not func.is_a? WaidForeignInstanceFunction
      addRuntimeError("#{func.type} is not callable.", node.Token)
    end

    # Si es un acceso a atributo, por ejemplo algo así:
    #
    # pos => !(Vector'pos 24)
    if node.Function.is_a? AttributeAccessExpression
      id = node.Function.Attribute
      #stack_frame = evalNode(node.Function.Object).Env
      stack_frame = StackFrame.new(id.Value)
      stack_frame.define("this", evalNode(node.Function.Object))

    # Si es un acceso a un módulo, por ejemplo:
    #
    # num => !(math::cos 45)
    #
    # Entonces:
    elsif node.Function.is_a? ModuleAccessExpression

      # Aumentamos el stack de módulo. Esta es otra bandera para decirle al
      # interpretador que está corriendo código de un archivo distinto al
      # principal. Si el valor es distinto de 0, estamos dentro de un módulo.
      @is_module += 1

      # El identificador es el objeto que buscamos
      id = node.Function.Object

      # Este es el stackframe del módulo. En el ejemplo de más arriba sería
      # "math"
      stack_frame = evalNode(node.Function.Module).StackFrame

      # Esto lo vamos a usar para ver si estamos llamando a un módulo nativo o
      # a uno Foreign, queriendo decir que fue creado con la ffi
      mod = evalNode(node.Function.Module)

      # Si es un módulo y una función nativa, empujar el stack del módulo al
      # CallStack y crear un nuevo StackFrame con el nombre de la función
      if not mod.is_a? WaidForeignModule and not func.is_a? WaidForeignFunction
        @runtime_stack.push(stack_frame)
        stack_frame = StackFrame.new(id.Value, @runtime_stack.getTopMost)
      end

    # Si es una función normal en el archivo principal, creamos un StackFrame
    # con su nombre.
    else
      id = node.Function
      stack_frame = StackFrame.new(id.Value, @runtime_stack.getTopMost)
    end

    # Empujamos el nuevo StackFrame de la función al CallStack
    @runtime_stack.push(stack_frame)

    length = arguments.length
    if arguments.none? # Si arguments queda como [nil]
      length = 0
    end

    # Si la cantidad de argumentos no es la misma que la cantidad de
    # parámetros, tiramos un error.
    if func.Arity != length
      addRuntimeError("'#{id.Value}' takes #{func.Arity} positional arguments, but #{length} were given.", node.Token)
    end

    # Si es una función Builtin o una función creada con ffi, la llamamos y
    # popeamos el CallStack
    if func.is_a? WaidBuiltin or func.is_a? WaidForeignFunction
      a = func.Function.call(*arguments)
      @runtime_stack.pop

      if not node.ErrorVariable.is_a? Empty
        @runtime_stack.define(node.ErrorVariable.Value, a.Error)
      end

      return a

    elsif func.is_a? WaidForeignInstanceFunction
      a = func.call(evalNode(node.Function.Object), *arguments)
      @runtime_stack.pop

      if not node.ErrorVariable.is_a? Empty
        @runtime_stack.define(node.ErrorVariable.Value, a.Error)
      end

      return a
    end

    # Definimos los argumentos dentro del StackFrame de la función
    func.Parameters.each_with_index do |par, index|
      @runtime_stack.define(par.Value, arguments[index])
    end

    # Corremos la función
    res = evalStatementList(func.Body)

    # Si la función no devolvió nada, esto es, la bandera de ReturnState nunca
    # se activó, hacemos que la función devuelva null
    if not @runtime_stack.isReturnState
      res = WaidReturnTuple.new(NullValue, NullValue)
    end

    if node.Function.is_a? ModuleAccessExpression and inModuleContext
      # Si la función era de un módulo le restamos uno al stack y popeamos un
      # StackFrame
      @runtime_stack.pop
    end

    # Si no estábamos en un módulo, popeamos un StackFrame
    if not inModuleContext and not node.is_a? ModuleAccessExpression
      @runtime_stack.pop
    end

    # Popeamos el StackFrame de la función
    @runtime_stack.pop

    if not node.ErrorVariable.is_a? Empty
      @runtime_stack.define(node.ErrorVariable.Value, res.Error)
    else
      # Si no hay variable de error, devolvamos el valor solamente
      res = res.Value
    end
    res
  end


  # Inicializa un record.
  # Ejemplo:
  #
  # v1 => !{Vector 2 4}
  def initRecord(node)
    id = node.Identifier
    arguments = evalExpressions(node.Arguments)
    record = evalNode(id)

    if id.is_a? ModuleAccessExpression
      id = id.Object
    end

    record_instance = WaidRecordInstance.new

    record_instance.Identifier = id

    record_instance.Env = StackFrame.new(id.Value)

    record_instance.Env.makeLinkTo(@runtime_stack.getBottomMost)
    record.Env.memory_map.each do |key, val|
      record_instance.Env.define(key, val)
    end

    keys = record.Env.getAllNames
    length = arguments.length
    if arguments.none?
      length = 0
      record_instance.Env = record.Env
    else
      arguments.each_with_index do |val, index|
        record_instance.Env.define(keys[index], val)
      end
    end

    if arguments.length > keys.length
      addRuntimeError("'#{id}' expects a maximum of #{keys.length} arguments, but #{arguments.length} were given.", node.Token)
    end
    record_instance
  end

  def evalExpressions(expressions)
    res = Array.new
    expressions.each do |expr|
      ind_res = evalNode(expr)
      if ind_res
        if ind_res.is_a? WaidReturnTuple
          ind_res = ind_res.Value
        end
        res.push(ind_res)
      end
    end
    res
  end

  def evalArrayIndexAssignment(node)
    index = evalNode(node.Left.IndexExpression)
    if not index.is_a? WaidInteger
      addRuntimeError("Array index must be an integer, not of type #{index.type}", node.Token)
    elsif index.Value < 0
      addRuntimeError("Index #{index.Value} too small for array; minimun: 0", node.Token)
    end

    array = evalNode(node.Left.ArrayIdentifier)

    value = evalNode(node.Value)

    array.Values[index.Value] = value
  end

  def evalProgram(program)
    result = WaidObject.new
    program.Statements.each do |stmt|
      result = evalNode(stmt)
    end
    result
  end

  def evalNode(node)
    case node
    when Program

      if not inModuleContext
        ar = StackFrame.new("global", nil)
        @runtime_stack.push(ar)
        populateGlobals
      end

      res = evalProgram(node)

      if inModuleContext
        return @runtime_stack.pop
      end
      return res

    when IncludeStatement
      path = evalNode(node.Path)
      full_path = @error_collector.mainFile.getPath + "/" + path.Value + ".wd"
      if not File.file?(full_path)

        # Si no está relativo al archivo principal buscamos en stdlib
        full_path = File.expand_path(File.dirname(__FILE__)) + "/lib/" + path.Value + ".wd"
        if not File.file?(full_path)
          addRuntimeError("File '#{path.Value}.wd' not found", node.Token)
        end
      end
      source_file = WaidFile.new(full_path)

      @error_collector.addFile(source_file)

      tokenizer = Tokenizer.new(source_file, @error_collector)
      tokenizer.tokenize!

      if @error_collector.hasErrors
        @error_collector.showErrors
      end

      parser = Parser.new(tokenizer.tokens, @error_collector)
      parser.parse!

      if @error_collector.hasErrors
        @error_collector.showErrors
      end

      mod = StackFrame.new(path.Value)

      @runtime_stack.push(mod)

      populateGlobals

      @is_module += 1
      stack_frame = evalNode(parser.ast)

      @runtime_stack.define(node.Path.Value, WaidModule.new(full_path, stack_frame))

      @is_module -= 1
      return

    when VarDeclarationStatement
      value = evalNode(node.Value)

      case node.Left
      when Identifier
        if value.is_a? WaidReturnTuple
          value = value.Value
        end
        return @runtime_stack.define(node.Left.Value, value)
      when IndexAccessExpression
        # TODO
        return evalArrayIndexAssignment(node)
      end

    when RecordDeclarationStatement
      # Acá ningun valor, variable o función, dentro de la declaración del
      # record debería ser capaz de acceder a las variables globales. Para
      # hacer esto debo hacer que el atributo @previous de cada StackFrame
      # apunte a su propio "global" o la raíz del árbol de búsqueda. También se
      # puede pensar este atributo como el StackFrame arriba del
      # correspondiente a aquel en que se declaró la variable.
      # Luego implementamos en el CallStack que el órden de bpusqueda sea el
      # StackFrame de más arriba, luego el que viene, y por último el apuntado
      # por previous.
      # Lo permitiré por ahora porque me da paja hacerlo antes de terminar
      # todo. Saludos cordiales.

      #ar = StackFrame.new(node.Identifier.Value, @runtime_stack.getTopMost)
      ar = StackFrame.new(node.Identifier.Value)
      @runtime_stack.push(ar)

      node.VariableDeclarations.each do |vd|
        evalNode(vd)
      end

      node.InstanceFunctionDeclarations.each do |vd|
        evalNode(vd)
      end

      rec_literal = WaidRecord.new(ar)

      @runtime_stack.pop

      @runtime_stack.define(node.Identifier.Value, rec_literal)
      return rec_literal

    when RecordInitialize
      return initRecord(node)

    when IfStatement
      return evalIfStatement(node)

    when WhileStatement
      return evalWhileStatement(node)

    when FuncDeclarationStatement
      func_literal = WaidFunction.new(
        node.Parameters,
        node.Body,
        node.Parameters.length
      )
      @runtime_stack.define(node.Identifier.Value, func_literal)
      return node.Identifier

    when FunctionCall
      return evalFunctionCall(node)

    when ReturnStatement
      value = evalNode(node.ReturnValue)

      if node.ErrorValue.is_a? Empty
        error = WaidNull.new
      else
        error = evalNode(node.ErrorValue)
      end
      return WaidReturnTuple.new(value, error)

    when StatementList
      return evalStatementList(node)

      # Expressions
    when IntLiteral
      return WaidInteger.new(node.Value)

    when FloatLiteral
      return WaidFloat.new(node.Value)

    when BooleanLiteral
      return WaidBoolean.new(node.Value)

    when StringLiteral
      return WaidString.new(node.Value)

    when ArrayLiteral
      exprs = evalExpressions(node.Values)
      return WaidArray.new(exprs)

    when NullLiteral
      return WaidNull.new

    when BinaryOperatorExpression
      l_val = evalNode(node.Left)
      r_val = evalNode(node.Right)
      return evalBinaryOperatorExpression(node, l_val, r_val)

    when UnaryOperatorExpression
      expr = evalNode(node.Expression)
      return evalUnaryOperatorExpression(node, expr)

    when AttributeAccessExpression
      object = evalNode(node.Object)

      if not object.is_a? WaidRecordInstance
        addRuntimeError("'#{node.Object.Value}' is not a record", node.Object.Token)
      end

      @runtime_stack.push(object.Env)
      attr = evalNode(node.Attribute)

      @runtime_stack.pop
      return attr

    when ModuleAccessExpression
      mod = evalNode(node.Module)

      if not mod.is_a? WaidModule and not mod.is_a? WaidForeignModule
        addRuntimeError("'#{node.Module}' is not a module", node.Module.Token)
      end

      @runtime_stack.push(mod.StackFrame)

      obj = evalNode(node.Object)

      @runtime_stack.pop
      return obj


    when Identifier
      value = @runtime_stack.resolveName(node.Value)
      if not value
        addRuntimeError("Undeclared variable '#{node.Value}'", node.Token)
      end

      return value
    end
  end

  def populateGlobals
    $builtins.each do |key, val|
      @runtime_stack.define(key, val)
    end
  end

  def run
    evalNode(@ast)
  end
end
