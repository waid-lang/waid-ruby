require_relative 'token'
require_relative '../common/source_position'

$keywords = {
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

def is_keyword(word)
  $keywords.key?(word)
end

def is_whitespace(char)
  char =~ /\s/
end

def is_valid_id_char(char)
  !char.match(/\A[a-zA-Z0-9_]*\z/).nil?
end

class String
  def is_number?
    true if Float(self) rescue false
  end
end

class Tokenizer
  attr_accessor :tokens
  def initialize(source, debug, err_coll)
    @source = source
    @debug = debug
    @error_collector = err_coll

    @tokens = Array.new

    @line_number = 1
    @column_number = -1 # No sé por qué -1, pero si parto en 0 todo se va a la b
    @current_line = String.new

    @current_char = String.new
    @peek_char = @source[@column_number]
  end

  def add_token(tt, value=nil)
    @tokens << Token.new(
      tt,
      SourcePosition.new(
        @line_number,
        @column_number,
        @source.line_indexes.last,
        @source
      ),
      value
    )
  end

  def add_syntax_error(desc)
     @error_collector.add_error(
       CompilationError.new(
         desc,
         get_full_line,
         SourcePosition.new(
           @line_number,
           @column_number,
           @source.line_indexes.last,
           @source
         )
       )
     )
  end

  def get_full_line
    line = String.new
    line_start = @source.line_indexes.last
    while @source[line_start] and not @source[line_start].eql? "\n"
      line += @source[line_start]
      line_start += 1
    end
    line
  end

  def push_char
    @current_char = @peek_char

    # El peek char se encuentra en el índice actua +1
    @column_number += 1
    @peek_char = @source[@column_number + 1]

    @current_line += @current_char? @current_char : ""

    if @current_char == "\n"
      @line_number += 1
      @source.line_indexes.push(@column_number + 1)
    end
    @current_char
  end

  def read_until(char)
    res = String.new
    while @current_char != char
      res += @current_char
      push_char
    end
    res
  end

  def check_comment
    if @current_char == "\#"
      push_char
      @tokens << Token.new(
        TokenKind::COMMENT,
        SourcePosition.new(
          @line_number,
          @column_number,
          @source.line_indexes.last,
          @source
        ),
        read_until("\n")
      )
      true
    end
    false
  end

  def check_operator
    t = case @current_char
        when '+'
          @peek_char == '>'? TokenKind::OP_PLUS_ASSIGN : TokenKind::OP_PLUS
          push_char
        when '-'
          @peek_char == '>'? TokenKind::OP_MINUS_ASSIGN : TokenKind::OP_MINUS
          push_char
        when '*'
          @peek_char == '>'? TokenKind::OP_ASTERISK_ASSIGN : TokenKind::OP_ASTERISK
          push_char
        when '/'
          @peek_char == '>'? TokenKind::OP_SLASH_ASSIGN : TokenKind::OP_SLASH
          push_char
        when '%'
          @peek_char == '>'? TokenKind::OP_MODULUS_ASSIGN : TokenKind::OP_MODULUS
          push_char
        when '='
          if @peek_char == ">"
            push_char
            TokenKind::OP_ASSIGN
          else
            return false
          end
        when '<'
          @peek_char == '-'? TokenKind::OP_RETURN : TokenKind::OP_LESS
          push_char
        when '!'
          TokenKind::OP_EXCLAMATION
        when ','
          TokenKind::OP_COMMA
        when '.'
          TokenKind::OP_DOT
        when ':'
          TokenKind::OP_COLON
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
        add_token(t)
        true
  end

  def check_literal
    num = String.new
    if @current_char.is_number?
      tt = -1
      num += @current_char
      while @peek_char.is_number?
        push_char
        num += @current_char
        push_char
      end
      if @peek_char == "."
        num += @peek_char
        push_char

        if not @peek_char.is_number?
          add_syntax_error("Malformed floating point number.")
          return true
        end

        while @peek_char.is_number?
          push_char
          num += @current_char
        end
        tt = TokenKind::LITERAL_FLOAT       
      else
        tt = TokenKind::LITERAL_INT
      end
      add_token(tt, num)
      push_char
      return true
    end
    false
  end

  def check_word
    word = String.new
    if is_valid_id_char(@current_char)
      tt = -1
      word += @current_char
      while is_valid_id_char(@peek_char)
        push_char
        word += @current_char
      end
      if is_keyword(word)
        tt = $keywords[word]
      else
        tt = TokenKind::IDENTIFIER
      end
      add_token(tt, word)
      return true
    end
    false
  end

  def tokenize
    while push_char
      if check_comment or check_operator or check_literal or check_word
        next
      else
        if not is_whitespace(@current_char)
          error = "Unknown char '#{@current_char}'."
          add_syntax_error(error)
        end
        next
      end
    end
    add_token(TokenKind::EOF)
  end
end
