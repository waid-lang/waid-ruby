require_relative 'token'
require_relative '../common/source_position'

# Mapa con cada palabra clave y su correspondiente TokenKind
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
  "record" => TokenKind::KEY_RECORD,
  "endrc" => TokenKind::KEY_ENDRC,
  "and" => TokenKind::KEY_AND,
  "or" => TokenKind::KEY_OR,
  "not" => TokenKind::KEY_NOT,
  "true" => TokenKind::KEY_TRUE,
  "false" => TokenKind::KEY_FALSE,
  "null" => TokenKind::KEY_NULL
}

# No necesita explicación
def is_keyword(word)
  $keywords.key?(word)
end

# Tampoco...
def is_whitespace(char)
  char =~ /\s/
end

# Los carácteres válidos para un identificador son [A-Za-z0-9_]
def is_valid_id_char(char)
  !char.match(/\A[a-zA-Z0-9_]*\z/).nil?
end

# Los carácteres válidos para el INICIO de un identificador son [A-Za-z_]
def is_valid_first_id_char(char)
  !char.match(/\A[a-zA-Z_]*\z/).nil?
end

# Extendemos la clase String para verificar si un literal efectivamente
# corresponde solamente a un número.
class String
  def is_number?
    true if Float(self) rescue false
  end
end

# Siento que debo escribir un comentario gigante para esta clase que es una de
# las más importantes del programa, pero no tiene mucha más explicación.
#
# Tokenizer es la única parte del compilador que accede directamente al cpodigo
# fuente. Este recibe un programa de Waid (y un ErrorCollector) y devuelve un
# Arreglo de Tokens.
#
# Por ejemplo para el siguiente programa:
#
# x => 0
# while x < 20:
#     !(printLine x)
#     x => x + i
# endwl
#
# Tokenizer produce los siguientes Tokens:
#
# 1| IDENTIFIER x
# 1| => 
# 1| LITERAL_INT 0
# 2| WHILE while
# 2| IDENTIFIER x
# 2| < 
# 2| LITERAL_INT 20
# 2| : 
# 3| ! 
# 3| ( 
# 3| IDENTIFIER printLine
# 3| IDENTIFIER x
# 3| ) 
# 4| IDENTIFIER x
# 4| => 
# 4| IDENTIFIER x
# 4| + 
# 4| IDENTIFIER i
# 5| ENDWL endwl
# 6| EOF
class Tokenizer
  attr_accessor :tokens
  def initialize(source, err_coll)
    @source = source
    @error_collector = err_coll

    @tokens = Array.new

    # Número de línea actual
    @line_number = 1
    
    # Número de columna en la línea actual
    @column_number = 0

    # Linea completa actual
    @current_line = String.new

    # Caracter actual
    @current_char = String.new

    # Caracter siguiente
    @peek_char = @source[@column_number]
  end

  # addToken: TokenKind, Any -> nil
  def addToken(tt, value=nil)
    # Se ve feo, pero estoy añadiendo un nuevo token con todos los parámetros
    # actuales al arreglo tokens
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

  # Añadir un error de sintaxis. desc es la descripción del error.
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

  # Obtener línea completa.
  # TODO: Sacar esta función porque es la misma que está en ErrorCollector.
  # No sé por qué la hice de nuevo.
  def getFullLine
    line = String.new
    line_start = @source.line_indexes.last
    while @source[line_start] and not @source[line_start].eql? "\n"
      line += @source[line_start]
      line_start += 1
    end
    line
  end

  # Empujamos el stck de chars:
  # El actual se vuelve el siguiente y el siguiente lee uno nuevo.
  # Además sumamos uno al número de línea.
  def pushChar
    @current_char = @peek_char

    # El peek char se encuentra en el índice actua +1
    @column_number += 1
    @peek_char = @source[@column_number]

    # Si ya no hay más carácteres, empezamo
    @current_line += @current_char? @current_char : ""

    if @current_char == "\n"
      @line_number += 1

      # Añadimos el número de línea al arreglo de índices de WaidFile
      @source.line_indexes.push(@column_number)
    end
    @current_char
  end

  # Acumulamos todos los caracteres hasta llegar a "char". Luego devolvemos ese
  # string.
  def readUntil(char)
    res = String.new
    while @current_char != char
      res += @current_char
      pushChar
    end
    res
  end

  # Si la línea inicia con un "#" es un comentario; leemos todo hasta el salto
  # de línea y lo ignoramos, luego devolvemos true. Si no es un comentario
  # devolvemos false
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

  # Es básicamente un switch gigante viendo el cáracter actual. Si este (o
  # estos en caso de operadores multicaracter) calzan con un operador, añade el
  # nuevo token y devuelve true, en caso contrario false.
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
          elsif @peek_char == '='
            pushChar
            TokenKind::OP_NOT_EQUAL
          else
            TokenKind::OP_SLASH
          end
        when "%"
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
          else
            return
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
        when '@'
          TokenKind::OP_AT
        when ','
          TokenKind::OP_COMMA
        when '.'
          TokenKind::OP_DOT
        when '\''
          TokenKind::OP_SINGLE_QUOTE
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
        when '{'
          TokenKind::OP_OPEN_CURLYBRACES
        when '}'
          TokenKind::OP_CLOSE_CURLYBRACES
        else
          return false
        end
    addToken(t)
    true
  end

  # Acá verificamos si desde el caracter actual podemos generar un literal. Los
  # literales posibles son un WaidString, WaidInteger, y WaidFloat. Si se
  # encuentra lo añadimos al arreglo de tokens y devolvemos true, en caso
  # contrario false.
  def checkLiteral
    lit = String.new
    if @current_char == '"'
      tt = TokenKind::LITERAL_STRING
      pushChar

      # Acá podría haber usado "readUntil", pero eso habría permitido strings
      # con saltos de línea, así que hice que leyera hasta encontrarse con otro
      # ", pero si se encuentra un salto de línea en medio, arroja un error de
      # sintaxis.
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

      # Si hay un punto es un float
      if @peek_char == "."
        lit += @peek_char
        pushChar

        # Si no hay nada después del punto, arroja error.
        # Podría hacer como otros lenguajes y aceptar flotantes como
        # 5. o 1232., pero francamente no me gusta y es poco claro.
        #
        # TODO: Implmentar flotantes tipo:
        # 10e-3 || 10E2
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
        # TODO: Implementar enteros con otras bases. Ejemplo:
        # Base 2: 0b1011001
        # Base 16: 0xBEEF, 0x4B1D
        tt = TokenKind::LITERAL_INT
      end
      addToken(tt, lit)
      return true
    end
    false
  end

  # Verifica la existencia de un identificador (o una keyword) desde el
  # caracter actual. Si la encuentra, la añade y devuelve true, caso contrario
  # false.
  def checkWord
    word = String.new
    if is_valid_first_id_char(@current_char)
      tt = -1
      word += @current_char
      while is_valid_id_char(@peek_char)
        pushChar
        word += @current_char
      end

      # Si la palabra que encontramos es una keyword, el TokenKind del token
      # será el establecido en el Mapa al comienzo
      if is_keyword(word)
        tt = $keywords[word]
      else
        # En caso contrario es un identificador normal
        tt = TokenKind::IDENTIFIER
      end
      addToken(tt, word)
      return true
    end
    false
  end

  # Función principal
  def tokenize!
    while pushChar
      # Acá nos aprovechamos de una optimización bien exquisita de los
      # operadores booleanos.
      # El interpretador evaluará cada una de estas funciones una por una, pero
      # apenas encuentre una que devuelva true, entrará al if y no ejecutará el
      # resto. Hablando de eso, quiero implementarlo en el lenguaje. que sea un
      # TODO.
      if checkWord or checkComment or check_operator or checkLiteral
        next
      else
        # Si no es nada de lo de arriba, y no es espacio en blanco, ni idea qué
        # es: Error de sintaxis.
        if not is_whitespace(@current_char)
          error = "Unknown char '#{@current_char}'."
          addSyntaxError(error)
        end
        next
      end
    end

    # El último token del arreglo siempre será EOF
    addToken(TokenKind::EOF)
  end
end
