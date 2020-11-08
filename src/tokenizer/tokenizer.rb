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
  "and" => TokenKind::KEY_AND,
  "or" => TokenKind::KEY_OR,
  "not" => TokenKind::KEY_NOT,
  "true" => TokenKind::KEY_TRUE,
  "false" => TokenKind::KEY_FALSE,
  "null" => TokenKind::KEY_NULL
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

def is_valid_first_id_char(char)
  !char.match(/\A[a-zA-Z_]*\z/).nil?
end

class String
  def is_number?
    true if Float(self) rescue false
  end
end

class Tokenizer
  attr_accessor :tokens
  def initialize(source, err_coll)
    @source = source
    @error_collector = err_coll

    @tokens = Array.new

    @line_number = 1
    @column_number = 0
    @current_line = String.new

    @current_char = String.new
    @peek_char = @source[@column_number]
  end

  def addToken(tt, value=nil)
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

  def addSyntaxError(desc)
    @error_collector.addError(
      CompilationError.new(
        desc,
        getFullLine,
        SourcePosition.new(
          @line_number,
          @column_number,
          @source.line_indexes.last,
          @source
        )
      )
    )
  end

  def getFullLine
    line = String.new
    line_start = @source.line_indexes.last
    while @source[line_start] and not @source[line_start].eql? "\n"
      line += @source[line_start]
      line_start += 1
    end
    line
  end

  def pushChar
    @current_char = @peek_char

    # El peek char se encuentra en el índice actua +1
    @column_number += 1
    @peek_char = @source[@column_number]

    @current_line += @current_char? @current_char : ""

    if @current_char == "\n"
      @line_number += 1
      @source.line_indexes.push(@column_number)
    end
    @current_char
  end

  def readUntil(char)
    res = String.new
    while @current_char != char
      res += @current_char
      pushChar
    end
    res
  end

  def checkComment
    if @current_char == "\#"
      pushChar
      #@tokens << Token.new(
      #  TokenKind::COMMENT,
      #  SourcePosition.new(
      #    @line_number,
      #    @column_number,
      #    @source.line_indexes.last,
      #    @source
      #  ),
        readUntil("\n")
      #)
      true
    end
    false
  end

  def check_operator
    t = case @current_char
        when '+'
          # TODO: Función para generalizar estos if-else
          if @peek_char == ">"
            pushChar
            TokenKind::OP_PLUS_ASSIGN
          else
            TokenKind::OP_PLUS
          end
        when '-'
          if @peek_char == ">"
            pushChar
            TokenKind::OP_MINUS_ASSIGN
          else
            TokenKind::OP_MINUS
          end
        when '*'
          if @peek_char == ">"
            pushChar
            TokenKind::OP_ASTERISK_ASSIGN
          else
            TokenKind::OP_ASTERISK
          end
        when '/'
          if @peek_char == '>'
            pushChar
            TokenKind::OP_SLASH_ASSIGN
          else
            TokenKind::OP_SLASH
          end
        when '%'
          @peek_char == '>'? TokenKind::OP_MODULUS_ASSIGN : TokenKind::OP_MODULUS
          pushChar
          if @peek_char == '>'
            pushChar
            TokenKind::OP_MODULUS_ASSIGN
          else
            TokenKind::OP_MODULUS
          end
        when '='
          if @peek_char == ">"
            pushChar
            TokenKind::OP_ASSIGN
          elsif @peek_char == '='
            pushChar
            TokenKind::OP_EQUAL
          end
        when '<'
          if @peek_char == "-"
            pushChar
            TokenKind::OP_RETURN
          elsif @peek_char == '='
            pushChar
            TokenKind::OP_LESS_EQUAL
          else
            TokenKind::OP_LESS
          end
        when '>'
          if @peek_char == "="
            pushChar
            TokenKind::OP_GREATER_EQUAL
          else
            TokenKind::OP_GREATER
          end
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
    addToken(t)
    true
  end

  def checkLiteral
    lit = String.new
    if @current_char == '"'
      tt = TokenKind::LITERAL_STRING
      pushChar
      while @current_char != '"'
        lit += @current_char
        if @peek_char == "\n"
          addSyntaxError("Unexpected EOL reading string literal")
          pushChar
          return
        end
        pushChar
      end
      addToken(tt, lit)
      return true
    elsif @current_char.is_number?
      tt = -1
      lit += @current_char
      while @peek_char.is_number?
        pushChar
        lit += @current_char
      end
      if @peek_char == "."
        lit += @peek_char
        pushChar

        if not @peek_char.is_number?
          addSyntaxError("Malformed floating point number.")
          return true
        end

        while @peek_char.is_number?
          pushChar
          lit += @current_char
        end
        tt = TokenKind::LITERAL_FLOAT       
      else
        tt = TokenKind::LITERAL_INT
      end
      addToken(tt, lit)
      return true
    end
    false
  end

  def checkWord
    word = String.new
    if is_valid_first_id_char(@current_char)
      tt = -1
      word += @current_char
      while is_valid_id_char(@peek_char)
        pushChar
        word += @current_char
      end
      if is_keyword(word)
        tt = $keywords[word]
      else
        tt = TokenKind::IDENTIFIER
      end
      addToken(tt, word)
      return true
    end
    false
  end

  def tokenize!
    while pushChar
      if checkWord or checkComment or check_operator or checkLiteral
        next
      else
        if not is_whitespace(@current_char)
          error = "Unknown char '#{@current_char}'."
          addSyntaxError(error)
        end
        next
      end
    end
    addToken(TokenKind::EOF)
  end
end
