require_relative '../parser/ast'
require_relative 'enviroment'
require_relative 'waid_object'
require_relative 'builtin'

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

  def boolToWaidBoolean(val)
    if val
      return TrueValue
    end
    FalseValue
  end


  def isTruthy(obj)
    if obj.is_a? WaidString
      if obj.Value == ""
        return false
      end
      return true
    end
    if obj.is_a? WaidBoolean
      return obj.Value
    end
    not obj.is_a? WaidNull
  end

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
      return WaidFloat.new(left.Value / right.Value)
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
    operator = node
    if left.is_a? WaidInteger and right.is_a? WaidInteger
      return evalIntegerBinaryOperatorexpression(node, left, right)

    elsif left.is_a? WaidFloat or right.is_a? WaidFloat
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
      when TokenKind::OP_EQUAL
        val = true
        if left.Values.length != right.Values.length
          val = false
        else
          left.Values.zip(right.Values).each do |l, r|
            if l.class != r.class
              val = false
              break
            else
              val = evalBinaryOperatorExpression(operator, l, r)
            end
          end
        end
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
      if @runtime_stack.isReturnState
        return res
      end
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
      if stmt.is_a? ReturnStatement
        @runtime_stack.setReturnState
      end
      if @runtime_stack.isReturnState
        return result
      end
    end
    result
  end

  def evalFunctionCall(node)
    arguments = evalExpressions(node.Arguments)
    func = evalNode(node.Function)
    if not func.is_a? WaidFunction and not func.is_a? WaidBuiltin
      addRuntimeError("#{func.type} is not callable.", node.Token)
    end

    if node.Function.is_a? AttributeAccessExpression
      id = node.Function.Attribute
      rec_inst = evalNode(node.Function.Object)
      @runtime_stack.push(rec_inst.Env)

    elsif node.Function.is_a? ModuleAccessExpression
      id = node.Function.Object
      stack_frame = evalNode(node.Function.Module).StackFrame
      @runtime_stack.push(stack_frame)
    else
      id = node.Function
      ar = StackFrame.new(id.Value, @runtime_stack.getTopMost)
      @runtime_stack.push(ar)
    end

    length = arguments.length
    if arguments.none?
      length = 0
    end
    if func.Arity != length
      addRuntimeError("'#{id.Value}' takes #{func.Arity} positional arguments, but #{length} were given.", node.Token)
    end

    if func.is_a? WaidBuiltin
      a = func.Function.call(*arguments)
      @runtime_stack.pop
      return a
    end

    #puts "CALLING #{id.Value}"
    #puts "PARAMETERS"
    func.Parameters.each_with_index do |par, index|
      #puts "\t#{par.Value} => #{arguments[index].inspect}"
      @runtime_stack.define(par.Value, arguments[index])
    end
    #puts "END PARAMETERS"
    res = evalStatementList(func.Body)

    if not @runtime_stack.isReturnState
      res = NullValue
    end

    @runtime_stack.pop
    res
  end

  def initRecord(node)
    id = node.Identifier
    arguments = evalExpressions(node.Arguments)
    record = evalNode(id)

    if id.is_a? ModuleAccessExpression
      id = id.Module
    end

    record_instance = WaidRecordInstance.new

    record_instance.Identifier = id

    record_instance.Env = StackFrame.new(id.Value)
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

      a = evalProgram(node)

      if inModuleContext
        return @runtime_stack.pop
      end
      return a

    when IncludeStatement
      path = evalNode(node.Path)
      full_path = @error_collector.mainFile.getPath + "/" + path.Value + ".wd"
      if not File.file?(full_path)
        addRuntimeError("File '#{path.Value}.wd' not found", node.Token)
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

      mod = StackFrame.new(path)
      mod.makeLinkTo(@runtime_stack.getTopMost)

      @runtime_stack.push(mod)

      @is_module += 1
      stack_frame = evalNode(parser.ast)

      @runtime_stack.define(node.Path.Value, WaidModule.new(full_path, stack_frame))

      @is_module -= 1
      return

    when VarDeclarationStatement
      value = evalNode(node.Value)

      case node.Left
      when Identifier
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
      ar = StackFrame.new(node.Identifier.Value, @runtime_stack.getTopMost)
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
      return evalNode(node.ReturnValue)

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
      r_val = evalNode(node.Right)
      l_val = evalNode(node.Left)

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
 
      if not mod.is_a? WaidModule
        addRuntimeError("'#{node.Module.Value}' is not a module", node.Module.Token)
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
