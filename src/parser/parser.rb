require_relative 'ast'
require_relative '../tokenizer/token'
require_relative '../common/error_collector'

class Parser
  attr_accessor :ast
  def initialize(tokens, err_coll)
    @tokens = tokens.each
    @error_collector = err_coll

    @current_token = nil
    @peek_token = nil

    @ast = Programa.new

    pushToken
    pushToken
  end

  def pushToken
    @current_token = @peek_token
    begin
      @peek_token = @tokens.next
    rescue StopIteration => err
      @peek_token = nil
    end
  end

  def currentTokenEquals(tok)
    @current_token.kind == tok
  end

  def peekTokenEquals(tok)
    @peek_token.kind == tok
  end

  def consumePeek(token_kind)
    if peekTokenEquals(token_kind)
      pushToken
      return true
    end
    @error_collector.addError(CompilationError.new(
      "Expected '#{token_string(token_kind)}', but got '#{@peek_token}' instead.",
      @error_collector.getLine(@peek_token.source_position),
      @peek_token.source_position
    ))
    @error_collector.showErrors
    return nil
  end

  def parse!
    # PROGRAMA = {LISTA_STMTS};
    while not currentTokenEquals(TokenKind::EOF)
      statement = parseStatement
      if statement
        @ast.Statements.push(statement)
      end
      pushToken
    end
  end

  def parseStatement
    # ESTAMENTO = DECL_VARIABLE
    #           | DECL_FUNC
    #           | RETURN_STMT
    #           | IF_STMT
    #           | WHILE_STMT
    #           | EXPR;
    case @current_token.kind
    when TokenKind::IDENTIFIER # Puede ser declaración de función o de variable
      if peekTokenEquals(TokenKind::OP_COLON)
        return parseFunctionDeclStatement
      elsif peekTokenEquals(TokenKind::OP_ASSIGN)
        return parseVarDeclStatement
      end
    when TokenKind::OP_RETURN
      return parseReturnStatement
    when TokenKind::KEY_IF
      return parseIfStatement
    when TokenKind::KEY_WHILE
      return parseWhileStatement
    when TokenKind::OP_EXCLAMATION
      return parseFunctionCall
    else
      return nil
    end
  end

  def parseVarDeclStatement
    # DECL_VARIABLE = IDENTIFICADOR, "=>", EXPR;
    statement = VarDeclarationStatement.new
    #if not consumePeek(TokenKind::IDENTIFIER)
    #return nil
    #end
    statement.Identifier = Identifier.new(@current_token.value)

    # TODO: Implementar todo esto como un método y que lo añada como error
    if not consumePeek(TokenKind::OP_ASSIGN)
      return nil
    end
    #pushToken

    statement.Value = parseExpression
    statement
  end

  def parseFunctionDeclStatement
    # DECL_FUNC   = DECL_TIPO, TIPO_FUNC, CUERPO_FUNC;
    # CUERPO_FUNC = "=>", LISTA_STMTS, "endfn";
    # DECL_TIP    = IDENTIFICADOR, ":";
    # TIPO_FUNC        = "func", PARAMETROS
    statement = FuncDeclarationStatement.new

    statement.Identifier = Identifier.new(@current_token.value)

    if not consumePeek(TokenKind::OP_COLON)
      return nil
    end

    if not consumePeek(TokenKind::KEY_FUNC)
      return nil
    end

    statement.Parameters = parseFunctionParameters

    if not consumePeek(TokenKind::OP_ASSIGN)
      return nil
    end

    statement.Body = parseStatementList

    if not consumePeek(TokenKind::KEY_ENDFN)
      return nil
    end
    statement
  end

  def parseFunctionParameters
    # PARAMETROS = "(", [LISTA_PARAMS], ")";
    # LISTA_PARAMS     = PARAM_DECL, {",", PARAM_DECL};
    # PARAM_DECL       = IDENTIFICADOR, [VALOR_DEFECTO];
    # VALOR_DEFECTO    = "=>", OPERANDO; // TODO
    identifiers = Array.new

    if not consumePeek(TokenKind::OP_OPEN_PARENTHESIS)
      return nil
    end

    if peekTokenEquals(TokenKind::OP_CLOSE_PARENTHESIS)
      pushToken
      return identifiers
    end

    if not consumePeek(TokenKind::IDENTIFIER)
      return nil
    end

    identifiers.push(Identifier.new(@current_token.value))

    # TODO
    while peekTokenEquals(TokenKind::OP_COMMA)
      pushToken
      pushToken

      identifiers.push(Identifier.new(@current_token.value))
    end

    if not consumePeek(TokenKind::OP_CLOSE_PARENTHESIS)
      return nil
    end
    identifiers
  end

  def parseStatementList
    # LISTA_STMTS = {ESTAMENTO};
    list = StatementList.new
    while not peekTokenEquals(TokenKind::KEY_ENDFN) and \
        not peekTokenEquals(TokenKind::KEY_ENDWL) and \
        not peekTokenEquals(TokenKind::KEY_ENDIF) and \
        not peekTokenEquals(TokenKind::KEY_ELSE) and \
        not peekTokenEquals(TokenKind::EOF)
      pushToken
      statement = parseStatement
      if statement
        list.push(statement)
      end
    end
    list
  end

  def parseReturnStatement
    # RETURN_STMTS = "<-", EXPR;
    statement = ReturnStatement.new
    statement.ReturnValue = parseExpression
    return statement
  end

  def parseIfStatement
    stmt = IfStatement.new
    stmt.Condition = parseExpression

    # Definimos elsebody al tiro por si no sale nada
    stmt.ElseBody = StatementList.new

    if not consumePeek(TokenKind::OP_ASSIGN)
      return nil
    end

    stmt.Body = parseStatementList

    if peekTokenEquals(TokenKind::KEY_ELSE)
      pushToken
      consumePeek(TokenKind::OP_ASSIGN)
      stmt.ElseBody = parseStatementList
    end

    if not consumePeek(TokenKind::KEY_ENDIF)
      return nil
    end
    stmt
  end

  def parseWhileStatement
    stmt = WhileStatement.new
    stmt.Condition = parseExpression

    if not consumePeek(TokenKind::OP_ASSIGN)
      return nil
    end

    stmt.Body = parseStatementList

    if not consumePeek(TokenKind::KEY_ENDWL)
      return nil
    end
    stmt
  end

  def parseExpressionStatement
    nil
  end

  def parseExpression
    parseBooleanOrExpression
  end

  def parseBooleanOrExpression
    expr = parseBooleanAndExpression
    while peekTokenEquals(TokenKind::KEY_OR)
      pushToken
      expr = BinaryOperatorExpression.new(expr, @current_token, parseBooleanAndExpression)
    end
    expr
  end

  def parseBooleanAndExpression
    expr = parseBooleanNegExpression
    while peekTokenEquals(TokenKind::KEY_AND)
      pushToken
      expr = BinaryOperatorExpression.new(expr, @current_token, parseBooleanNegExpression)
    end
    expr
  end

  def parseBooleanNegExpression
    if peekTokenEquals(TokenKind::KEY_NOT)
      pushToken
      return UnaryOperatorExpression.new(@current_token, parseBooleanNegExpression)
    end
    parseCompareExpression
  end

  def parseCompareExpression
    expr = parseRelationalExpression
    while peekTokenEquals(TokenKind::OP_EQUAL) or peekTokenEquals(TokenKind::OP_NOT_EQUAL)
      pushToken
      expr = BinaryOperatorExpression.new(expr, @current_token, parseRelationalExpression)
    end
    expr
  end

  def parseRelationalExpression
    expr = parseArithmeticExpression
    while peekTokenEquals(TokenKind::OP_GREATER) or peekTokenEquals(TokenKind::OP_LESS) \
        or peekTokenEquals(TokenKind::OP_GREATER_EQUAL) or peekTokenEquals(TokenKind::OP_LESS_EQUAL)
      pushToken
      expr = BinaryOperatorExpression.new(expr, @current_token, parseArithmeticExpression)
    end
    expr
  end

  def parseArithmeticExpression
    # EXPR_ARITMETICA  = MULT, {OP_SUMA, MULT};
    # OP_SUMA          = "+"
    #                  | "-";
    expr = parseMultiplicationExpression
    while peekTokenEquals(TokenKind::OP_PLUS) or peekTokenEquals(TokenKind::OP_MINUS)
      pushToken
      expr = BinaryOperatorExpression.new(expr, @current_token, parseMultiplicationExpression)
    end
    expr
  end

  def parseMultiplicationExpression
    # MULT    = NEG, {OP_MULT, NEG};
    # OP_MULT = "*"
    #         | "/"
    #         | "%"
    expr = parseNegativeExpression
    while peekTokenEquals(TokenKind::OP_ASTERISK) or peekTokenEquals(TokenKind::OP_SLASH) \
        or peekTokenEquals(TokenKind::OP_MODULUS)
      pushToken
      expr = BinaryOperatorExpression.new(expr, @current_token, parseNegativeExpression)
    end
    expr
  end

  def parseNegativeExpression
    # NEG = "-", NEG
    #     | EXPR_ARIT_SEC;
    if peekTokenEquals(TokenKind::OP_MINUS)
      pushToken
      return UnaryOperatorExpression.new(@current_token, parseNegativeExpression)
    end
    parsePrimaryExpression
  end

  def parsePrimaryExpression
    # EXPR_PRIMARIA = OPERANDO
    #               | FUNC_CALL;
    if peekTokenEquals(TokenKind::OP_EXCLAMATION)
      consumePeek(TokenKind::OP_EXCLAMATION)
      return parseFunctionCall
    end
    return parseOperand
  end

  def parseFunctionCall
    expr = FunctionCall.new
    #consumePeek(TokenKind::OP_EXCLAMATION)

    if peekTokenEquals(TokenKind::OP_OPEN_PARENTHESIS)
      # Tiene argumentos
      pushToken
      if not consumePeek(TokenKind::IDENTIFIER)
        return nil
      end

      expr.Function = Identifier.new(@current_token.value)
      expr.Arguments.push(parseExpression)

      if not peekTokenEquals(TokenKind::OP_CLOSE_PARENTHESIS)
        expr.Arguments.push(parseExpression)
      end
      
      expr_ = parseExpression
      while expr_
        expr.Arguments.push(expr_)
        expr_ = parseExpression
      end

      if not consumePeek(TokenKind::OP_CLOSE_PARENTHESIS)
        return nil
      end
      return expr
    end
      # Sin argumentos
    if not consumePeek(TokenKind::IDENTIFIER)
      return nil
    end
    expr.Function = Identifier.new(@current_token.value)
    expr.Arguments.push(Empty.new)
    expr
  end

  def parseOperand
    case @peek_token.kind
    when TokenKind::IDENTIFIER
      consumePeek(TokenKind::IDENTIFIER)
      operand = Identifier.new(@current_token.value)
    when TokenKind::OP_OPEN_PARENTHESIS
      consumePeek(TokenKind::OP_OPEN_PARENTHESIS)
      operand = parseExpression
      consumePeek(TokenKind::OP_CLOSE_PARENTHESIS)
    when TokenKind::LITERAL_INT
      consumePeek(TokenKind::LITERAL_INT)
      operand = IntLiteral.new(@current_token.value)
    when TokenKind::LITERAL_FLOAT
      consumePeek(TokenKind::LITERAL_FLOAT)
      operand = FloatLiteral.new(@current_token.value)
    when TokenKind::KEY_TRUE
      consumePeek(TokenKind::KEY_TRUE)
      operand = BooleanLiteral.new(@current_token.value)
    else
      return nil
    end
    operand
  end
end
