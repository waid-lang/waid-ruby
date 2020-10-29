class SourcePosition
  attr_accessor :line, :column, :source_column, :source_line_column, :source_file
  def initialize(line, source_column, source_line_column, source_file)
    @line = line
    @column = source_column - source_line_column
    @source_column = source_column
    @source_line_column = source_line_column
    @source_file = source_file
  end
end
