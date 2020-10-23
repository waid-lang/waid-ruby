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
            "Expected '#{token_kind}', but got '#{@peek_token}' instead.",
            "TODO: Ver cómo añadir la línea completa :(",
            @peek_token.source_position
        ))
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
        # TIPO_FUNC        = "func", PARAMETROS;
        # PARAMETROS       = "(", [LISTA_PARAMS], ")";
        # LISTA_PARAMS     = PARAM_DECL, {",", PARAM_DECL};
        # PARAM_DECL       = IDENTIFICADOR, [VALOR_DEFECTO];
        # VALOR_DEFECTO    = "=>", OPERANDO;
        statement = FuncDeclarationStatement.new

        if not consumePeek(TokenKind::IDENTIFIER)
            return nil
        end
        statement.Identifier = @current_token.value

        if not consumePeek(TokenKind::OP_COLON)
            return nil
        end

        if not consumePeek(TokenKind::KEY_FUNC)
            return nil
        end

        if not consumePeek(TokenKind::OP_OPEN_PARENTHESIS)
            return nil
        end

        statement.Parameters = parseFunctionParameters

        if not consumePeek(TokenKind::OP_CLOSE_PARENTHESIS)
            return nil
        end

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
    end

    def parseReturnStatement
    end

    def parseIfStatement
    end

    def parseWhileStatement
    end

    def parseExpressionStatement
    end

    def parseExpression
    end
end