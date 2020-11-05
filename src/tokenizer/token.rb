module TokenKind
  # Misc
  EOF                  = 0x00
  COMMENT              = 0x01
  IDENTIFIER           = 0x02

  # Literals
  LITERAL_INT          = 0x03
  LITERAL_FLOAT        = 0x04
  LITERAL_STRING       = 0x05

  # Keywords
  KEY_WHILE            = 0x06
  KEY_ENDWL            = 0x07
  KEY_FUNC             = 0x08
  KEY_ENDFN            = 0x09
  KEY_FOR              = 0x0A
  KEY_IN               = 0x0B
  KEY_ENDFR            = 0x0C
  KEY_IF               = 0x0D
  KEY_ELSE             = 0x0E
  KEY_ELIF             = 0x0F
  KEY_ENDIF            = 0x10
  KEY_AND              = 0x11
  KEY_OR               = 0x12
  KEY_NOT              = 0x13
  KEY_TRUE             = 0x14
  KEY_FALSE            = 0x15

  OP_PLUS              = 0x16
  OP_MINUS             = 0x17
  OP_ASTERISK          = 0x18
  OP_SLASH             = 0x19
  OP_MODULUS           = 0x1A
  OP_ASSIGN            = 0x1B
  OP_PLUS_ASSIGN       = 0x1C
  OP_MINUS_ASSIGN      = 0x1D
  OP_ASTERISK_ASSIGN   = 0x1E
  OP_SLASH_ASSIGN      = 0x1F
  OP_MODULUS_ASSIGN    = 0x20
  OP_LESS              = 0x21
  OP_GREATER           = 0x22
  OP_EQUAL             = 0x23
  OP_NOT_EQUAL         = 0x24
  OP_LESS_EQUAL        = 0x25
  OP_GREATER_EQUAL     = 0x26
  OP_RETURN            = 0x27
  OP_EXCLAMATION       = 0x28

  OP_COMMA             = 0x29
  OP_COLON             = 0x2A
  OP_DOT               = 0x2B
  OP_OPEN_PARENTHESIS  = 0x2C
  OP_CLOSE_PARENTHESIS = 0x2D
  OP_OPEN_BRACKETS     = 0x2E
  OP_CLOSE_BRACKETS    = 0x2F
end

def token_string(tok)
  s = case tok
      when TokenKind::EOF
        "EOF"
      when TokenKind::COMMENT
        "COMMENT"
      when TokenKind::IDENTIFIER
        "IDENTIFIER"
      when TokenKind::LITERAL_INT
        "LITERAL_INT"
      when TokenKind::LITERAL_FLOAT
        "LITERAL_FLOAT"
      when TokenKind::LITERAL_STRING
        "LITERAL_STRING"
        #when TokenKind::LITERAL_STRING_INTERPOLATED
        #  "LITERAL_STRING_INTERPOLATED"

      when TokenKind::KEY_FUNC
        "FUNC"
      when TokenKind::KEY_ENDFN
        "ENDFN"
      when TokenKind::KEY_WHILE
        "WHILE"
      when TokenKind::KEY_ENDWL
        "ENDWL"
      when TokenKind::KEY_FOR
        "FOR"
      when TokenKind::KEY_ENDFR
        "ENDFR"
      when TokenKind::KEY_IF
        "IF"
      when TokenKind::KEY_ELSE
        "ELSE"
      when TokenKind::KEY_ELIF
        "ELSEIF"
      when TokenKind::KEY_ENDIF
        "ENDIF"
      when TokenKind::KEY_AND
        "AND"
      when TokenKind::KEY_OR
        "OR"
      when TokenKind::KEY_NOT
        "NOT"
      when TokenKind::KEY_TRUE
        "TRUE"
      when TokenKind::KEY_FALSE
        "FALSE"
      when TokenKind::OP_PLUS
        "+"
      when TokenKind::OP_MINUS
        "-"
      when TokenKind::OP_ASTERISK
        "*"
      when TokenKind::OP_SLASH
        "/"
      when TokenKind::OP_MODULUS
        "%"
      when TokenKind::OP_ASSIGN
        "=>"
      when TokenKind::OP_PLUS_ASSIGN
        "+>"
      when TokenKind::OP_MINUS_ASSIGN
        "->"
      when TokenKind::OP_ASTERISK_ASSIGN
        "*>"
      when TokenKind::OP_SLASH_ASSIGN
        "/>"
      when TokenKind::OP_MODULUS_ASSIGN
        "%>"
      when TokenKind::OP_LESS
        "<"
      when TokenKind::OP_GREATER
        ">"
      when TokenKind::OP_EQUAL
        "=="
      when TokenKind::OP_NOT_EQUAL
        "/="
      when TokenKind::OP_LESS_EQUAL
        "<="
      when TokenKind::OP_GREATER_EQUAL
        ">="
      when TokenKind::OP_RETURN
        "<-"
      when TokenKind::OP_EXCLAMATION
        "!"
        #when TokenKind::OP_AT
        #  "@"

      when TokenKind::OP_COMMA
        ","
      when TokenKind::OP_COLON
        ":"
        #when TokenKind::OP_SEMICOLON
        #  ";"
      when TokenKind::OP_DOT
        "."
      when TokenKind::OP_OPEN_PARENTHESIS
        "("
      when TokenKind::OP_CLOSE_PARENTHESIS
        ")"
      when TokenKind::OP_OPEN_BRACKETS
        "["
      when TokenKind::OP_CLOSE_BRACKETS
        "]"
        #when TokenKind::OP_OPEN_CURLYBRACES
        #  "{"
        #when TokenKind::OP_CLOSE_CURLYBRACES
        #  "}"

        #when TokenKind::END
        #  "END"
      end
  s
end

# TODO: Implementar como Struct mejor (?)
class Token
  attr_accessor :value
  attr_reader :kind
  attr_reader :source_position
  # Sería bueno implementar una clase que represente la posición en el código
  # fuente.
  def initialize(token_kind, source_pos, value=nil)
    @kind = token_kind
    @value = value
    @source_position = source_pos
  end

  def get_line_number
    @source_position.line
  end

  def get_column_number
    @source_position.column
  end

  def get_source_offset
    @source_position.source_line_column
  end

  def to_s
    token_string(@kind)
  end
end
