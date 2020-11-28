require_relative 'ast'
require_relative '../tokenizer/token'
require_relative '../common/error_collector'

# Parser es el generador del árbol sintáctico de un programa en Waid. Es, según
# yo, la parte más importante de todo el proceso, pues tiene codificada
# directamente la gramática del lenguaje. El parser es el que verifica
# finalmente si un programa está bien escrito o no, esto es, si sigue las
# reglas gramaticales establecidas para el lenguaje.
#
# No hay mucho que añadir puesto que, siendo un parser recursivo descendiente,
# este es una traducción casi literal de la gramática del lenguaje (Esta está
# completa en "grammar.ebnf"). Por lo mismo, solo están comentadas las partes
# que no tienen una correlación directa con lo establecido en el archivo
# mencionado.
#
# En general, siempre que haga un cambio en "grammar.ebnf" también haré uno
# acá.
class Parser
  attr_accessor :ast
  def initialize(tokens, err_coll)
    @tokens = tokens.each
    @error_collector = err_coll

    @current_token = nil
    @peek_token = nil

    @ast = Program.new

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

  # TODO: Reescribir esta función para que reciba un Token
  # y no un SourcePosition.
  def addParseError(desc, sp)
    c_err = CompilationError.new(desc, sp)
    @error_collector.addError(c_err)
    @error_collector.showErrors
  end

  def consumePeek(token_kind)
    if peekTokenEquals(token_kind)
      pushToken
      return true
    end
    addParseError("Expected '#{token_string(token_kind)}', but got '#{@peek_token}' instead.", @peek_token.source_position)
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
    #           | DECL_RECORD
    #           | RETURN_STMT
    #           | IF_STMT
    #           | WHILE_STMT
    #           | EXPR;
    case @current_token.kind
    when TokenKind::OP_OPEN_PARENTHESIS
      return parseArrayElementDeclarationStatement
    when TokenKind::IDENTIFIER # Puede ser declaración de función o de variable
      id = @current_token
      if peekTokenEquals(TokenKind::OP_COLON)
        pushToken
        if peekTokenEquals(TokenKind::KEY_FUNC)
          return parseFunctionDeclStatement(id)
        elsif peekTokenEquals(TokenKind::KEY_RECORD)
          return parseRecordDeclStatement(id)
        end
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
      consumePeek(TokenKind::EOF)
    end
  end

  def parseArrayElementDeclarationStatement
    stmt = VarDeclarationStatement.new
    index_access_expr = IndexAccessExpression.new

    index_expr = parseExpression
    
    if not index_expr.is_a? BinaryOperatorExpression
      pushToken
      addParseError("Expected '@', but got #{@current_token} instead.", index_expr.Token.source_position)
    end
    index_access_expr.Token =  index_expr.Token
    if index_expr.Operator.kind != TokenKind::OP_AT
      addParseError("Expected '@', but got #{@peek_token} instead.", @peek_token.source_position)
    
    # No creo que este elsif sea necesario porque el nombre del arreglo podría surgir de una
    # expresión, por ejemplo:
    #
    # range: func(num) =>
    #     arr => []
    #     x => 0
    #     while x < num:
    #         arr => arr . x
    #     endwl
    # endfn
    #
    # length => 10
    # ((length / 2) @ !(range length)) => 0
    #elsif not index_expr.Right.is_a?(Identifier)
    #  addParseError("Expected 'IDENTIFIER', but got '#{@current_token}' instead.", @current_token.source_position)
    end

    consumePeek(TokenKind::OP_CLOSE_PARENTHESIS)
    consumePeek(TokenKind::OP_ASSIGN)

    index_access_expr.IndexExpression = index_expr.Left
    index_access_expr.ArrayIdentifier = index_expr.Right

    stmt.Left = index_access_expr
    stmt.Value = parseExpression
    stmt
  end

  def parseVarDeclStatement
    # DECL_VARIABLE = IDENTIFICADOR, "=>", EXPR;
    statement = VarDeclarationStatement.new
    #end
    statement.Left = Identifier.new(@current_token.value, @current_token)

    # TODO: Implementar todo esto como un método y que lo añada como error
    consumePeek(TokenKind::OP_ASSIGN)
    #pushToken
    statement.Token = @current_token

    statement.Value = parseExpression
    statement
  end

  def parseFunctionDeclStatement(id)
    # DECL_FUNC   = DECL_TIPO, TIPO_FUNC, CUERPO_FUNC;
    # CUERPO_FUNC = "=>", LISTA_STMTS, "endfn";
    # DECL_TIP    = IDENTIFICADOR, ":";
    # TIPO_FUNC        = "func", PARAMETROS
    statement = FuncDeclarationStatement.new

    statement.Identifier = Identifier.new(id.value, id)

    consumePeek(TokenKind::KEY_FUNC)
    statement.Token = @current_token

    statement.Parameters = parseFunctionParameters

    consumePeek(TokenKind::OP_ASSIGN)

    statement.Body = parseStatementList

    consumePeek(TokenKind::KEY_ENDFN)
    statement
  end

  def parseFunctionParameters
    # PARAMETROS = "(", [LISTA_PARAMS], ")";
    # LISTA_PARAMS     = PARAM_DECL, {",", PARAM_DECL};
    # PARAM_DECL       = IDENTIFICADOR, [VALOR_DEFECTO];
    # VALOR_DEFECTO    = "=>", OPERANDO; // TODO
    identifiers = Array.new

    consumePeek(TokenKind::OP_OPEN_PARENTHESIS)

    if peekTokenEquals(TokenKind::OP_CLOSE_PARENTHESIS)
      pushToken
      return identifiers
    end

    consumePeek(TokenKind::IDENTIFIER)

    identifiers.push(Identifier.new(@current_token.value, @current_token))

    # TODO
    while peekTokenEquals(TokenKind::OP_COMMA)
      pushToken
      pushToken

      identifiers.push(Identifier.new(@current_token.value, @current_token))
    end

    consumePeek(TokenKind::OP_CLOSE_PARENTHESIS)
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

  def parseRecordDeclStatement(id)
    consumePeek(TokenKind::KEY_RECORD)
    consumePeek(TokenKind::OP_ASSIGN)
    rec_decl = RecordDeclarationStatement.new
    rec_decl.Identifier = Identifier.new(id.value, id)

    while peekTokenEquals(TokenKind::IDENTIFIER)
      var_decl = VarDeclarationStatement.new
      var_decl.Left = Identifier.new(@peek_token.value, @peek_token)
      pushToken

      consumePeek(TokenKind::OP_ASSIGN)

      var_decl.Value = parseExpression
      rec_decl.VariableDeclarations.push(var_decl)
    end

    if peekTokenEquals(TokenKind::KEY_INSTANCE)
      pushToken
      consumePeek(TokenKind::OP_COLON)

      while peekTokenEquals(TokenKind::IDENTIFIER)
        id = @peek_token
        pushToken
        pushToken
        rec_decl.InstanceFunctionDeclarations.push(parseFunctionDeclStatement(id))
      end
    end

    consumePeek(TokenKind::KEY_ENDRC)
    rec_decl
  end

  def parseReturnStatement
    # RETURN_STMTS = "<-", EXPR;
    statement = ReturnStatement.new
    statement.Token = @current_token
    statement.ReturnValue = parseExpression
    return statement
  end

  def parseIfStatement
    stmt = IfStatement.new
    stmt.Token = @current_token
    stmt.Condition = parseExpression

    if not stmt.Condition
      addParseError("Expected expression for if statement.", @current_token.source_position)
    end

    # Definimos elsebody al tiro por si no sale nada
    stmt.ElseBody = StatementList.new

    #consumePeek(TokenKind::OP_ASSIGN)
    consumePeek(TokenKind::OP_COLON)

    stmt.Body = parseStatementList

    if peekTokenEquals(TokenKind::KEY_ELSE)
      pushToken
      #consumePeek(TokenKind::OP_ASSIGN)
      consumePeek(TokenKind::OP_COLON)
      stmt.ElseBody = parseStatementList
    end

    consumePeek(TokenKind::KEY_ENDIF)
    stmt
  end

  def parseWhileStatement
    stmt = WhileStatement.new
    stmt.Token = @current_token
    stmt.Condition = parseExpression

    #consumePeek(TokenKind::OP_ASSIGN)
    consumePeek(TokenKind::OP_COLON)

    stmt.Body = parseStatementList

    consumePeek(TokenKind::KEY_ENDWL)
    stmt
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
    expr = parseAtExpression
    while peekTokenEquals(TokenKind::OP_ASTERISK) or peekTokenEquals(TokenKind::OP_SLASH) \
        or peekTokenEquals(TokenKind::OP_MODULUS)
      pushToken
      expr = BinaryOperatorExpression.new(expr, @current_token, parseAtExpression)
    end
    expr
  end

  def parseAtExpression
    expr = parseDotExpression
    while peekTokenEquals(TokenKind::OP_AT)
      pushToken
      expr = BinaryOperatorExpression.new(expr, @current_token, parseDotExpression)
    end
    expr
  end



  def parseDotExpression
    expr = parseNegativeExpression
    while peekTokenEquals(TokenKind::OP_AT) or peekTokenEquals(TokenKind::OP_DOT)
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
    operand = nil

    if peekTokenEquals(TokenKind::OP_EXCLAMATION)
      consumePeek(TokenKind::OP_EXCLAMATION)
      if peekTokenEquals(TokenKind::OP_OPEN_PARENTHESIS) or peekTokenEquals(TokenKind::IDENTIFIER)
        operand = parseFunctionCall
      elsif peekTokenEquals(TokenKind::OP_OPEN_CURLYBRACES)
        operand = parseRecordInit
      end
    else
      operand = parseOperand
    end

    # Por ahora solo tengo implementado el acceso a un atributo a la vez, es
    # decir, no puedo hacer algo tipo:
    #
    # pos_x => vector_1'posicion'x
    #
    # Tendría que hacerlo de 2 formas:
    #
    # 1) pos => vector_1'posicion
    #    pos_x => pos'x
    #
    # 2) pos_x => (vector_1'posicion)'x
    if peekTokenEquals(TokenKind::OP_SINGLE_QUOTE)

      pushToken
      consumePeek(TokenKind::IDENTIFIER)
      attr_acc = AttributeAccessExpression.new(operand, Identifier.new(@current_token.value, @current_token))
      return attr_acc
    end
    operand
  end

  def parseFunctionCall
    expr = FunctionCall.new
    expr.Token = @current_token
    #consumePeek(TokenKind::OP_EXCLAMATION)
    if peekTokenEquals(TokenKind::OP_OPEN_PARENTHESIS)
      # Tiene argumentos
      pushToken

      expr.Function = parsePrimaryExpression

      expr.Arguments.push(parseExpression)

      if not peekTokenEquals(TokenKind::OP_CLOSE_PARENTHESIS)
        expr.Arguments.push(parseExpression)
      end

      expr_ = parseExpression
      while expr_
        expr.Arguments.push(expr_)
        expr_ = parseExpression
      end

      consumePeek(TokenKind::OP_CLOSE_PARENTHESIS)
      return expr
    end
      # Sin argumentos
    expr.Function = parsePrimaryExpression
    expr.Arguments.push(Empty.new)
    expr
  end

  def parseRecordInit
    expr = RecordInitialize.new
    expr.Token = @current_token
    #consumePeek(TokenKind::OP_EXCLAMATION)
    if peekTokenEquals(TokenKind::OP_OPEN_CURLYBRACES)
      # Tiene argumentos
      pushToken
      consumePeek(TokenKind::IDENTIFIER)

      expr.Identifier = Identifier.new(@current_token.value, @current_token)

      if not peekTokenEquals(TokenKind::OP_CLOSE_CURLYBRACES)
        expr.Arguments.push(parseExpression)
      end
      
      expr_ = parseExpression
      while expr_
        expr.Arguments.push(expr_)
        expr_ = parseExpression
      end

      consumePeek(TokenKind::OP_CLOSE_CURLYBRACES)
      return expr
    end
      # Sin argumentos
    consumePeek(TokenKind::IDENTIFIER)
    expr.Identifier = Identifier.new(@current_token.value, @current_token)
    expr.Arguments.push(Empty.new)
    expr
  end


  def parseArrayLiteral
    elements = Array.new

    expr_ = parseExpression

    elements.push(expr_)

    # TODO
    while peekTokenEquals(TokenKind::OP_COMMA)
      pushToken
      expr_ = parseExpression
      elements.push(expr_)
    end

    # Manera fea, horrenda, y perturbadora de hacerlo
    if elements.length == 1 and elements[0].is_a?(NilClass)
      elements = []
    end
    elements
  end

  def parseOperand
    case @peek_token.kind
    when TokenKind::IDENTIFIER
      consumePeek(TokenKind::IDENTIFIER)
      operand = Identifier.new(@current_token.value, @current_token)
    when TokenKind::OP_OPEN_PARENTHESIS
      consumePeek(TokenKind::OP_OPEN_PARENTHESIS)
      operand = parseExpression
      consumePeek(TokenKind::OP_CLOSE_PARENTHESIS)
    when TokenKind::OP_OPEN_BRACKETS
      consumePeek(TokenKind::OP_OPEN_BRACKETS)
      operand = ArrayLiteral.new

      operand.Values = parseArrayLiteral
      consumePeek(TokenKind::OP_CLOSE_BRACKETS)
    when TokenKind::LITERAL_INT
      consumePeek(TokenKind::LITERAL_INT)
      operand = IntLiteral.new(@current_token.value)
    when TokenKind::LITERAL_FLOAT
      consumePeek(TokenKind::LITERAL_FLOAT)
      operand = FloatLiteral.new(@current_token.value)
    when TokenKind::LITERAL_STRING
      consumePeek(TokenKind::LITERAL_STRING)
      operand = StringLiteral.new(@current_token.value)
    when TokenKind::KEY_TRUE
      consumePeek(TokenKind::KEY_TRUE)
      operand = BooleanLiteral.new(@current_token.value)
    when TokenKind::KEY_FALSE
      consumePeek(TokenKind::KEY_FALSE)
      operand = BooleanLiteral.new(@current_token.value)
    when TokenKind::KEY_NULL
      consumePeek(TokenKind::KEY_NULL)
      operand = NullLiteral.new
    else
      return nil
    end
    operand
  end
end
