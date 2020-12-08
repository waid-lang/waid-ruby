
# Estos son todos los tipos de Tokens que Waid posee. Hay lexers que usan
# strings nomás, pero ellos no saben ná B).
# Mejor hacer un enum y que cada token esté representado por un número debajo
# de la mesa.
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
  KEY_RECORD           = 0x11
  KEY_ENDRC            = 0x12
  KEY_INSTANCE         = 0x13
  KEY_AND              = 0x14
  KEY_OR               = 0x15
  KEY_NOT              = 0x16
  KEY_TRUE             = 0x17
  KEY_FALSE            = 0x18
  KEY_NULL             = 0x19
  KEY_INCLUDE          = 0x1A

  OP_PLUS              = 0x1B
  OP_MINUS             = 0x1C
  OP_ASTERISK          = 0x1D
  OP_SLASH             = 0x1E
  OP_MODULUS           = 0x1F
  OP_ASSIGN            = 0x20
  OP_PLUS_ASSIGN       = 0x21
  OP_MINUS_ASSIGN      = 0x22
  OP_ASTERISK_ASSIGN   = 0x23
  OP_SLASH_ASSIGN      = 0x24
  OP_MODULUS_ASSIGN    = 0x25
  OP_LESS              = 0x26
  OP_GREATER           = 0x27
  OP_EQUAL             = 0x28
  OP_NOT_EQUAL         = 0x29
  OP_LESS_EQUAL        = 0x2A
  OP_GREATER_EQUAL     = 0x2B
  OP_RETURN            = 0x2C
  OP_EXCLAMATION       = 0x2D
  OP_AT                = 0x2E
  OP_ASSIGN_ERROR      = 0x2F

  OP_COMMA             = 0x30
  OP_COLON             = 0x31
  OP_DOUBLE_COLON      = 0x32
  OP_DOT               = 0x33
  OP_SINGLE_QUOTE      = 0x34
  OP_OPEN_PARENTHESIS  = 0x35
  OP_CLOSE_PARENTHESIS = 0x36
  OP_OPEN_BRACKETS     = 0x37
  OP_CLOSE_BRACKETS    = 0x38
  OP_OPEN_CURLYBRACES  = 0x39
  OP_CLOSE_CURLYBRACES = 0x3A
end

# token_string: TokenKind -> String
# Me devuelve una representación en string del tok
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
      when TokenKind::KEY_RECORD
        "RECORD"
      when TokenKind::KEY_ENDRC
        "ENDRC"
      when TokenKind::KEY_INSTANCE
        "INSTANCE"
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
      when TokenKind::KEY_NULL
        "NULL"
      when TokenKind::KEY_INCLUDE
        "INCLUDE"
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
      when TokenKind::OP_AT
        "@"
      when TokenKind::OP_ASSIGN_ERROR
        "~>"
      when TokenKind::OP_COMMA
        ","
      when TokenKind::OP_COLON
        ":"
      when TokenKind::OP_DOUBLE_COLON
        "::"
      when TokenKind::OP_DOT
        "."
      when TokenKind::OP_SINGLE_QUOTE
        "'"
      when TokenKind::OP_OPEN_PARENTHESIS
        "("
      when TokenKind::OP_CLOSE_PARENTHESIS
        ")"
      when TokenKind::OP_OPEN_BRACKETS
        "["
      when TokenKind::OP_CLOSE_BRACKETS
        "]"
      when TokenKind::OP_OPEN_CURLYBRACES
        "{"
      when TokenKind::OP_CLOSE_CURLYBRACES
        "}"

        #when TokenKind::END
        #  "END"
      end
  s # "s" xd
end

# TODO: Implementar como Struct mejor (?)
# Token representa un token en Waid. Garsias, esa explicación no sirvió de
# nada.
class Token
  attr_accessor :value
  attr_reader :kind
  attr_reader :source_position

  def initialize(token_kind, source_pos, value=nil)

    # El TokenKind
    @kind = token_kind

    # El valor del token si es que existe. Por ejemplo:
    # kind = LiteralInt, value = 10
    # Se entiende...
    @value = value

    # Posición en el código fuente del token
    # T = SourcePosition
    @source_position = source_pos
  end

  # Getters
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
