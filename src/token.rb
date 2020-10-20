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

  OP_PLUS              = 0x11
  OP_MINUS             = 0x12
  OP_ASTERISK          = 0x13
  OP_SLASH             = 0x14
  OP_MODULUS           = 0x15
  OP_ASSIGN            = 0x16
  OP_PLUS_ASSIGN       = 0x17
  OP_MINUS_ASSIGN      = 0x18
  OP_ASTERISK_ASSIGN   = 0x19
  OP_SLASH_ASSIGN      = 0x1A
  OP_MODULUS_ASSIGN    = 0x1B
  OP_LESS              = 0x1C
  OP_GREATER           = 0x1D
  OP_EQUAL             = 0x1E
  OP_NOT_EQUAL         = 0x1F
  OP_LESS_EQUAL        = 0x10
  OP_GREATER_EQUAL     = 0x21
  OP_RETURN            = 0x22
  OP_EXCLAMATION       = 0x23
  
  OP_COMMA             = 0x24
  OP_COLON             = 0x25
  OP_DOT               = 0x26
  OP_OPEN_PARENTHESIS  = 0x27
  OP_CLOSE_PARENTHESIS = 0x28
  OP_OPEN_BRACKETS     = 0x29
  OP_CLOSE_BRACKETS    = 0x2A
end

class Token
  attr_accessor :value
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
    # TODO
  end
end
