require_relative 'token'

keywords = {
  "func" => TokenKind::KEY_FUNC,
  "endfn" => TokenKind::KEY_ENDFN,
  "while" => TokenKind::KEY_WHILE,
  "endwl" =>  TokenKind::KEY_ENDWL,
  "for" => TokenKind::KEY_FOR,
  "endfr" => TokenKind::KEY_ENDFR,
  "if" => TokenKind::KEY_IF,
  "else" => TokenKind::KEY_ELSE,
  "elif" => TokenKind::KEY_ELIF,
  "endif" => TokenKind::KEY_ENDIF,
  # "and" => TokenKind::KEY_AND,
  # "or" => TokenKind::KEY_OR,
  # "not" => TokenKind::KEY_NOT,
  # "true" => TokenKind::KEY_TRUE,
  # "false" => TokenKind::KEY_FALSE
}

class Tokenizer
  attr_accessor :tokens
  def initialize(source, debug, err_coll)
    @source = source
    @debug = debug
    @error_collector = err_coll

    @tokens = Array.new

    @current_index = 0
    @current_char = String.new
    @peek_char = @source[@current_index]
  end

  def push_char
    @current_char = @peek_char

    # El peek char se encuentra en el índice actua +1
    @current_index += 1
    @peek_char = @source[@current_index]

    return @current_char
  end

  def check_comment
    if @current_char == "\#"
      @tokens << Token(TokenKind::COMMENT, read_until("\n"))
      return true
    end
    return false
  end

  def check_operator
    t = case @current_char
        when '+'
          @peek_char == '>'? TokenKind::OP_PLUS_ASSIGN : TokenKind::OP_PLUS
        when '-'
          @peek_char == '>'? TokenKind::OP_MINUS_ASSIGN : TokenKind::OP_MINUS
        when '*'
          @peek_char == '>'? TokenKind::OP_ASTERISK_ASSIGN : TokenKind::OP_ASTERISK
        when '/'
          @peek_char == '>'? TokenKind::OP_SLASH_ASSIGN : TokenKind::OP_SLASH
        when '%'
          @peek_char == '>'? TokenKind::OP_MODULUS_ASSIGN : TokenKind::OP_MODULUS
        when '='
          if @peek_char == ">"
            push_char
            TokenKind::OP_ASSIGN
          else
            return false
          end
        when '!'
          TokenKind::OP_EXCLAMATION
        when ','
          TokenKind::OP_COMMA
        when '.'
          TokenKind::OP_DOT
        when '('
          TokenKind::OP_OPEN_PARENTHESIS
        when ')'
          TokenKind::OP_CLOSE_PARENTHESIS
        when '['
          TokenKind::OP_OPEN_BRACKETS
        when ']'
          TokenKind::OP_CLOSE_BRACKETS
        else
          return false
        end
  end

  def check_literal
    
  end

  def tokenize(*args)
    while push_char
      if check_comment or check_operator or check_literal or check_word
        next
      end
    end
  end
end
