# SourcePosition representa una posición en al código fuente.
# TODO: Hacer una estructura en vez de una clase
class SourcePosition
  attr_accessor :line, :column, :source_column, :source_line_column
  def initialize(line, source_column, source_line_column)

    # Número de línea en el código fuente
    @line = line

    # Índice en la línea
    @column = source_column - source_line_column

    # Índice en el código fuente completo
    @source_column = source_column

    # Índice de donde comienza la linea en el código fuente.
    # Es el índice de la posición en la que se encuentra en
    # WaidFile.line_indexes.
    @source_line_column = source_line_column
  end
end
