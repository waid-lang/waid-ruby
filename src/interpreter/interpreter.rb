require_relative '../parser/ast'
require_relative 'enviroment'
require_relative 'waid_object'

class Interpreter
  def initialize(ast, err_coll)
    @ast = ast
    @error_collector = err_coll

    # TODO: Escribir un constructor MainEnv que inicialice el ambiente con
    # todas las variables globales
    @main_enviroment = Enviroment.new
  end

  # DEBUG
  #def env
  #  @main_enviroment
  #end

  def addRuntimeError(message, token)
    c_err = CompilationError.new(message, token.source_position)
    @error_collector.addError(c_err)
    @error_collector.showErrors
  end

  def evalArrayIndexAssignment(node, env)
    index = evalNode(node.IndexEpression)
  end

  def evalNode(node, env)
    case node
    when Program
      return evalProgram(node, env)

    when VarDeclarationStatement
      value = evalNode(node.Value, env)

      case node.Left
      when Identifier
        env.set(node.Left.Value, value)
        return value
      when IndexAccessExpression
        return evalArrayIndexAssignment(node, env)
      end
    when IfStatement
    when WhileStatement
    when FuncDeclarationStatement
      func_literal = WaidFunction.new(
        node.Parameters,
        node.Body,
        env,
        node.Parameters.length
      )
      env.set(node.Identifier.Value, func_literal)
      node.Identifier
    end
  end

  def run
    evalNode(@ast, @main_enviroment)
  end

  def evalProgram(program, env)
    result = WaidObject.new
    program.Statements.each do |stmt|
      result = evalNode(stmt, env)
    end
    result
  end
end
