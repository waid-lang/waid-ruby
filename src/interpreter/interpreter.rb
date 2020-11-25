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

    # TODO: Escribir un constructor MainEnv que inicialice el ambiente con
    # todas las variables globales
    @global_enviroment = Enviroment.new
  end

  # DEBUG
  def env
    @global_enviroment
  end

  def addRuntimeError(message, token)
    c_err = CompilationError.new(message, token.source_position)
    @error_collector.addError(c_err)
    @error_collector.showErrors
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
      return WaidFloat.new(left.Value / right.Value)
    when TokenKind::OP_MODULUS
      return WaidInteger.new(left.Value % right.Value)
    when TokenKind::OP_LESS
      return boolToWaidBoolean(left.Value < right.Value)
    when TokenKind::OP_LESS_EQUAL
      return boolToWaidBoolean(left.Value <= right.Value)
    when TokenKind::OP_EQUAL
      return boolToWaidBoolean(left.Value == right.Value)
    when TokenKind::OP_GREATER
      return boolToWaidBoolean(left.Value > right.Value)
    end
  end

  def evalBooleanBinaryOperation(node, left, right)
    case node.Operator.kind
    when TokenKind::KEY_AND
      return boolToWaidBoolean(isTruthy(left) && isTruthy(right))
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

  def evalBinaryOperatorExpression(node, left, right, env)
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
              val = evalBinaryOperatorExpression(operator, l, r, env)
            end
          end
        end
        return boolToWaidBoolean(val)
      end

    elsif left.is_a? WaidInteger and right.is_a? WaidArray and node.Operator.kind == TokenKind::OP_AT
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

  def evalWhileStatement(node, env)
    res = WaidObject.new
    while isTruthy(evalNode(node.Condition, env))
      res = evalNode(node.Body, env)
      if res.is_a?(ReturnStatement)
        return res
      end
    end
    res
  end

  def evalIfStatement(node, env)
    condition = evalNode(node.Condition, env)
    if isTruthy(condition)
      return evalNode(node.Body, env)
    elsif not node.ElseBody.Statements.empty?
      return evalNode(node.ElseBody, env)
    end
    return NullValue
  end

  def resolveIdentifier(node, env, unscoped=false)
    if unscoped
      value = env.getGlobal(node.Value)
    else
      value = env.getLocal(node.Value)
    end
    if value
      return value
    end
    if $builtins.key?(node.Value)
      return $builtins[node.Value]
    end

    addRuntimeError("Undeclared variable '#{node.Value}'", node.Token)
  end

  def evalStatementList(node, env)
    result = WaidObject.new
    node.Statements.each do |stmt|
      result = evalNode(stmt, env)
      if result.is_a?(ReturnStatement)
        break
      end
      if stmt.is_a?(ReturnStatement)
        return stmt
      end
    end
    result
  end

  def evalFunctionStatementList(node, env)
    result = WaidObject.new
    node.Body.Statements.each do |stmt|
      result = evalNode(stmt, env)
      if result.is_a? ReturnStatement
        result = evalNode(result, env)
        break
      end
    end
    result
  end

  def evalFunctionCall(node, env)
    func = resolveIdentifier(node.Function, env, true)
    if not func.is_a? WaidFunction and not func.is_a? WaidBuiltin
      addRuntimeError("#{func.type} is not callable.", node.Token)
    end
    arguments = evalExpressions(node.Arguments, env)

    length = arguments.length
    if arguments.none?
      length = 0
    end
    if func.Arity != length
      addRuntimeError("'#{node.Function.Value}' takes #{func.Arity} positional arguments, but #{length} were given.", node.Token)
    end

    if func.is_a? WaidBuiltin
      return func.Function.call(*arguments)
    end

    func_env = Enviroment.new(env)
    
    func.Parameters.each_with_index do |par, index|
      func_env.set(par.Value, arguments[index])
    end
    evalFunctionStatementList(func, func_env)
  end

  def evalExpressions(expressions, env)
    res = Array.new
    expressions.each do |expr|
      ind_res = evalNode(expr, env)
      res.push(ind_res)
    end
    res
  end

  def evalArrayIndexAssignment(node, env)
    index = evalNode(node.Left.IndexExpression, env)
    if not index.is_a? WaidInteger
      addRuntimeError("Array index must be an integer, not of type #{index.type}", node.Token)
    elsif index.Value < 0
      addRuntimeError("Index #{index.Value} too small for array; minimun: 0", node.Token)
    end

    # Esto es para ver si el identificador existe en el scope actual
    evalNode(node.Left.ArrayIdentifier, env)

    value = evalNode(node.Value, env)
    env.setArrayObject(node.Left.ArrayIdentifier.Value, index.Value, value)
  end

  def evalProgram(program, env)
    result = WaidObject.new
    program.Statements.each do |stmt|
      result = evalNode(stmt, env)
    end
    result
  end

  def evalNode(node, env)
    case node
    when Program
      return evalProgram(node, env)

    when VarDeclarationStatement
      value = evalNode(node.Value, env)

      case node.Left
      when Identifier
        return env.set(node.Left.Value, value)
      when IndexAccessExpression
        return evalArrayIndexAssignment(node, env)
      end

    when RecordDeclarationStatement
      rec_env = Enviroment.new
      node.VariableDeclarations.each do |vd|
        evalNode(vd, rec_env)
      end
      rec_literal = WaidRecord.new(rec_env)
      env.set(node.Identifier.Value, rec_literal)
      return rec_literal

    when IfStatement
      return evalIfStatement(node, env)
    when WhileStatement
      return evalWhileStatement(node, env)
    when FuncDeclarationStatement
      func_literal = WaidFunction.new(
        node.Parameters,
        node.Body,
        env,
        node.Parameters.length
      )
      env.set(node.Identifier.Value, func_literal)
      return node.Identifier

    when FunctionCall
      return evalFunctionCall(node, env)

    when ReturnStatement
      return evalNode(node.ReturnValue, env)

    when StatementList
      return evalStatementList(node, env)

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
      exprs = evalExpressions(node.Values, env)
      return WaidArray.new(exprs)

    when NullLiteral
      return WaidNull.new

    when BinaryOperatorExpression
      l_val = evalNode(node.Left, env)
      r_val = evalNode(node.Right, env)
      return evalBinaryOperatorExpression(node, l_val, r_val, env)

    when UnaryOperatorExpression
      expr = evalNode(node.Expression, env)
      return evalUnaryOperatorExpression(node, expr)

    when Identifier
      return resolveIdentifier(node, env)
    end
  end

  def run
    evalNode(@ast, @global_enviroment)
  end
end
