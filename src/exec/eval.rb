require_relative '../parser/ast'
require_relative 'waid_object'
require_relative '../tokenizer/tokenizer'
require_relative 'builtin'

# No quiero comentar este archivo porque lo voy a reescribir desde cero :(
NullValue = WaidNull.new
TrueValue = WaidBoolean.new(true)
FalseValue = WaidBoolean.new(false)

def eval_node(node, env)
  case node
  when Program
    return evalProgram(node, env)

    # STATEMENTS
  when VarDeclarationStatement
    value = eval_node(node.Value, env)
    env.set_ob(node.Identifier.Value, value)

  when ArrayIndexDeclarationStatement
    return evalArrayIndexDeclaration(node, env)

  when IfStatement
    return evalIfStatement(node, env)

  when WhileStatement
    return evalWhileStatement(node, env)

  when FuncDeclarationStatement
    env.set_func(node.Identifier.Value, nil)
    func_literal = WaidFunction.new(
      node.Parameters,
      node.Body,
      env
    )
    env.set_func(node.Identifier.Value, func_literal)
    return func_literal

  when FunctionCall
    func = eval_node(node.Function, env)
    arguments = evalExpressions(node.Arguments, env)
    return callFunction(env, func, arguments)

  when ReturnStatement
    return eval_node(node.ReturnValue, env)

  when StatementList
    return evalStatementList(node, env)

    # EXPRESSIONS
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

  when UnaryOperatorExpression
    expr = eval_node(node.Expression, env)
    return evalUnaryOperatorExpression(node.Operator, expr)

  when BinaryOperatorExpression
    expr_l = eval_node(node.Left, env)
    # Acá debería revisar errores
    expr_r = eval_node(node.Right, env)
    return evalBinaryOperatorExpression(node.Operator, expr_l, expr_r, env)

  when Identifier
    return evalIdentifier(node, env)
  end
end

def isFalse(obj)
  if obj.is_a?(WaidString)
    if obj.Value == ""
      return true
    end
    return false
  end
  if obj.is_a?(WaidBoolean)
    if obj.Value
      return false
    end
    return true
  end
  obj.is_a?(WaidNull)
end

def evalProgram(program, env)
  res = WaidObject.new
  program.Statements.each do |stmt|
    res = eval_node(stmt, env)
  end
  res
end

def boolToWaidBoolean(val)
  if val
    return TrueValue
  end
  FalseValue
end

def evalArrayIndexDeclaration(node, env)
  index = eval_node(node.IndexExpression, env)
  if not index.is_a?(WaidInteger)
    puts "Error: Array index must be an Integer, not of type #{index.type}"
    exit()
  elsif index.Value < 0
    puts "Error: index #{index.Value} too small for array; minimum: 0"
    exit()
  end

  eval_node(node.ArrayIdentifier, env) # Esto es para ver si existe el identificador
  value = eval_node(node.Value, env)
  env.set_array_obj(node.ArrayIdentifier.Value, index.Value, value)
end

def evalUnaryOperatorExpression(operator, expr)
  case operator.kind
  when TokenKind::OP_MINUS
    return evalMinusOperatorExpression(expr)
  when TokenKind::KEY_NOT
    if expr.is_a?(WaidString) or expr.is_a?(WaidNull)
      val = isFalse(expr)
      return boolToWaidBoolean(val)
    end
    return boolToWaidBoolean(!expr.Value)
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

def evalBinaryOperatorExpression(operator, left, right, env)
  if left.is_a?(WaidInteger) and right.is_a?(WaidInteger)
    return evalIntegerBinaryOperatorexpression(operator, left, right)
  elsif left.is_a?(WaidFloat) or right.is_a?(WaidFloat)
    return evalFloatBinaryOperatorexpression(operator, left, right)
  elsif left.is_a?(WaidBoolean) and right.is_a?(WaidBoolean)
    return evalBooleanBinaryOperation(operator, left, right)
  elsif left.is_a?(WaidString) and right.is_a?(WaidString)
    return evalStringBinaryOperationExpression(operator, left, right)
  elsif left.is_a?(WaidArray) and right.is_a?(WaidArray) and operator.kind == TokenKind::OP_PLUS
    return right.Values + left.Values
  elsif left.is_a?(WaidInteger) and right.is_a?(WaidArray) and operator.kind == TokenKind::OP_AT
    return right.Values[left.Value]
  elsif left.is_a?(WaidInteger) and right.is_a?(WaidString) and operator.kind == TokenKind::OP_AT
    return WaidString.new(right.Value[left.Value])
  elsif left.is_a?(WaidFunction) and right.is_a?(WaidFunction) and operator.kind == TokenKind::OP_EQUAL
    return boolToWaidBoolean(left == right)
  elsif left.is_a?(WaidNull) and right.is_a?(WaidNull) and operator.kind == TokenKind::OP_EQUAL
    return WaidBoolean.new(true)
  elsif left.is_a?(WaidArray) and right.is_a?(WaidArray) and operator.kind == TokenKind::OP_DOT
    left.Values.push(right)
    return left
  elsif left.is_a?(WaidArray) and right.is_a?(WaidArray) and operator.kind == TokenKind::OP_EQUAL
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
  elsif left.is_a?(WaidArray) and operator.kind == TokenKind::OP_DOT
    left.Values.push(right)
    return left
  elsif [TokenKind::KEY_AND, TokenKind::KEY_OR].include? operator.kind
    return evalBooleanBinaryOperation(operator, left, right)
  else
    puts "Error: Type mismatch. Can not operate #{left.type} #{operator} #{right.type}"
    exit()
  end
end

def evalFloatBinaryOperatorexpression(operator, left, right)
  case operator.kind
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

def evalIntegerBinaryOperatorexpression(operator, left, right)
  case operator.kind
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

def evalBooleanBinaryOperation(operator, left, right)
  case operator.kind
  when TokenKind::KEY_AND
    return boolToWaidBoolean(!isFalse(left) && !isFalse(right))
  when TokenKind::KEY_OR
    return boolToWaidBoolean(!isFalse(left) || !isFalse(right))
  end
end

def evalStringBinaryOperationExpression(operator, left, right)
  case operator.kind
  when TokenKind::OP_DOT
    return WaidString.new(left.Value + right.Value)
  when TokenKind::OP_EQUAL
    return boolToWaidBoolean(left.Value == right.Value)
  end
end

def evalExpressions(expressions, env)
  res = Array.new
  expressions.each do |expr|
    ind_res = eval_node(expr, env)
    res.push(ind_res)
  end
  res
end

def newFunctionEnv(funcs, func, args)
  env = newInnerEnv
  func.Parameters.each_with_index do |par, index|
    env.set_ob(par.Value, args[index])
  end

  func.Env.Objects.each do |id, val|
    env.set_ob(id, val)
  end

  funcs.Functions.each do |id, val|
    env.set_func(id, val)
  end
  env
end

def callFunction(funcs, func, arguments)
  # ENV = func.Env
  case func
  when WaidFunction
    func_env = newFunctionEnv(funcs, func, arguments)
    return evalFunctionStatementList(func.Body, func_env)
  when WaidBuiltin
    return func.Function.call(*arguments)
  end
end

def evalIfStatement(node, env)
  condition = eval_node(node.Condition, env)
  if !isFalse(condition)
    return eval_node(node.Body, env)
  elsif not node.ElseBody.Statements.empty?
    return eval_node(node.ElseBody, env)
  end
  return NullValue
end

def evalWhileStatement(node, env)
  res = WaidObject.new
  while not isFalse(eval_node(node.Condition, env))
    res = eval_node(node.Body, env)
    if res.is_a?(ReturnStatement)
      return res
    end
  end
  res
end

def evalIdentifier(node, env)
  value = env.get(node.Value)
  if value
    return value
  end
  if $builtins.key?(node.Value)
    return $builtins[node.Value]
  end
  # Debería tener un sistema de error
  puts "NameError: Undefined variable '#{node.Value}'"
  exit() # Salida floja por ahora. TODO: Crear sistema de manjeo de excepciones en runtime
  return nil
end

def evalStatementList(node, env)
  result = WaidObject.new
  node.Statements.each do |stmt|
    result = eval_node(stmt, env)
    if result.is_a?(ReturnStatement)
      break
    end
    if stmt.is_a?(ReturnStatement)
      return stmt
    end
  end
  result
end

def evalFunctionStatementList(node, func_env)
  result = WaidObject.new
  node.Statements.each do |stmt|
    result = eval_node(stmt, func_env)
    if result.is_a?(ReturnStatement)
      result = eval_node(result, func_env)
      break
    end
  end
  return result
end
