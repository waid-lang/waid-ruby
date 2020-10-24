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
        if not consumePeek(TokenKind::IDENTIFIER)
            return nil
        end
        statement.Identifier = @current_token.value

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

        statement.Identifier = @current_token.value

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
        puts identifiers

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
        return nil
    end

    def parseExpressionStatement
        return nil
    end

    def parseExpression
        # EXPR = EXPR_BOOLEANA;
        parseBooleanExpression
    end

    def parseBooleanExpression
        return nil
    end
end