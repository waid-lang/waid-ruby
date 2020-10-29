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
    else
      return parseExpressionStatement
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
    pushToken

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
    return nil
  end

  def parseWhileStatement
    stmt = WhileStatement.new
    stmt.Condition = parseExpression

    if not consumePeek(TokenKind::OP_ASSIGN)
      return nil
    end

    stmt.Body = parseStatementList

    if not consumePeek(TokenKind::OP_ASSIGN)
      return nil
    end
    stmt
  end

  def parseExpressionStatement
    return nil
  end

  def parseExpression
    # EXPR = EXPR_BOOLEANA;
    parseBooleanExpression
  end

  def parseBooleanExpression
    # EXPR_BOOLEANA = RELATIONAL, {OP_EQUALITY, RELATIONAL};
    expr = parseRelationalExpression
    while peekTokenEquals(TokenKind::OP_EQUAL) or peekTokenEquals(TokenKind::OP_NOT_EQUAL)
      pushToken
      expr = BinaryExpressionStatement.new(expr, @current_token, parseRelationalExpression)
    end
    expr
  end

  def parseRelationalExpression
    # RELATIONAL = EXPR_BOOL_SEC, {OP_RELATIONAL, EXPR_BOOL_SEC};
    expr = parseSecondaryBooleanExpression
    while peekTokenEquals(TokenKind::OP_GREATER) or peekTokenEquals(TokenKind::OP_LESS) \
        or peekTokenEquals(TokenKind::OP_GREATER_EQUAL) or peekTokenEquals(TokenKind::OP_LESS_EQUAL)
      expr = BinaryExpressionStatement.new(expr, @current_token, parseSecondaryBooleanExpression)
    end
    expr
  end

  # TODO: Estar muy atento con este método. Algo puede fallar con los peek de
  # los paréntesis
  def parseSecondaryBooleanExpression
    # EXPR_BOOL_SEC    = "(", EXPR_BOOLEANA, ")"                                                  
    #                  | EXPR_ARITMETICA
    if not peekTokenEquals(TokenKind::OP_OPEN_PARENTHESIS)
      return parseArithmeticExpression
    end

    if not consumePeek(TokenKind::OP_OPEN_PARENTHESIS)
      return nil
    end

    expr = parseBooleanExpression

    if not consumePeek(TokenKind::OP_CLOSE_PARENTHESIS)
      return nil
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
      return parseNegativeExpression
    end
    parseSecondaryArithmeticExpression
  end

  def parseSecondaryArithmeticExpression
    # EXPR_ARIT_SEC = "(", EXPR_ARITMETICA, ")"
    #               | EXPR_PRIMARIA;
    if not peekTokenEquals(TokenKind::OP_OPEN_PARENTHESIS)
      return parsePrimaryExpression
    end

    if not consumePeek(TokenKind::OP_OPEN_PARENTHESIS)
      return nil
    end

    expr = parseArithmeticExpression

    if not consumePeek(TokenKind::OP_CLOSE_PARENTHESIS)
      return nil
    end
    expr
  end

  def parsePrimaryExpression
    # EXPR_PRIMARIA = OPERANDO
    #               | FUNC_CALL;
    if peekTokenEquals(TokenKind::OP_EXCLAMATION)
      return parseFunctionCall
    end
    return parseOperand
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
      operand = LiteralInt.new(@current_token.value)
    when TokenKind::LITERAL_FLOAT
    when TokenKind::LITERAL_STRING
    end
    operand
  end
end
