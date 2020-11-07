require_relative '../parser/ast'
require_relative 'object'
require_relative '../tokenizer/tokenizer'

def eval_node(node, env)
  case node
  when Program
    return evalProgram(node, env)
  
  # STATEMENTS
  when VarDeclarationStatement
    value = eval_node(node.Value, env)
    env.set(node.Identifier.Value, value)

  when FuncDeclarationStatement
    func_literal = WaidFunction.new(
      node.Parameters,
      node.Body,
      env
    )
    env.set(node.Identifier.Value, func_literal)

  when FunctionCall
    func = eval_node(node.Function, env)
    arguments = evalExpressions(node.Arguments, env)
    return callFunction(func, arguments)

  when ReturnStatement
    return eval_node(node.ReturnValue, env)

  when StatementList
    return evalStatementList(node, env)
    
  # EXPRESSIONS
  when IntLiteral
    return WaidInteger.new(node.Value)

  when FloatLiteral
    return WaidFloat.new(node.Value)

  when UnaryOperatorExpression
    expr = eval_node(node.Expression, env)
    return evalUnaryOperatorExpression(node.Operator, expr)

  when BinaryOperatorExpression
    expr_l = eval_node(node.Left, env)
    # Acá debería revisar errores
    expr_r = eval_node(node.Right, env)
    return evalBinaryOperatorExpression(node.Operator, expr_l, expr_r)

  when Identifier
    return evalIdentifier(node, env)
  end
end

def evalProgram(program, env)
  res = WaidObject.new
  program.Statements.each do |stmt|
    res = eval_node(stmt, env)
  end
  res
end

def evalUnaryOperatorExpression(operator, expr)
  case operator.kind
  when TokenKind::OP_MINUS
    return evalMinusOperatorExpression(expr)
  when TokenKind::KEY_NOT
    # TODO
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

def evalBinaryOperatorExpression(operator, left, right)
  if left.is_a?(WaidInteger) and right.is_a?(WaidInteger)
    return evalIntegerBinaryOperatorexpression(operator, left, right)
  elsif left.is_a?(WaidFloat) or right.is_a?(WaidFloat)
    return evalFloatBinaryOperatorexpression(operator, left, right)
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

def newFunctionEnv(func, args)
  env = newInnerEnv(func.Env)
  func.Parameters.each_with_index do |par, index|
    env.set(par.Value, args[index])
  end
  env
end

def callFunction(func, arguments)
  func_env = newFunctionEnv(func, arguments)
  func_res = eval_node(func.Body, func_env)
  func_res
end

def evalIdentifier(node, env)
  value = env.get(node.Value)
  if value
    return value
  end
  # Debería tener un sistema de error
  puts "Identifier not found #{node.Value}"
  exit() # Salida floja por ahora. TODO: Crear sistema de manjeo de excepciones en runtime
  return nil
end

def evalStatementList(node, env)
  result = WaidObject.new
  node.Statements.each do |stmt|
    result = eval_node(stmt, env)
  end
  result
end
