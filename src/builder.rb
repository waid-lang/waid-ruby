require_relative 'common/error_collector'
require_relative 'common/waid_exception'
require_relative 'common/file_util'
require_relative 'tokenizer/tokenizer'
require_relative 'parser/parser'

class Builder
  attr_writer :source_path
  def initialize()
    @show_tokens = false
    @show_ast = false
    @source_path = String.new
  end

  def set_show_tokens
    @show_tokens = true
  end

  def set_show_ast
    @show_ast = true
  end

  def run
    source_file = WaidFile.new(@source_path)

    error_collector = ErrorCollector.new(source_file)

    tokenizer = Tokenizer.new(source_file, error_collector)
    tokenizer.tokenize!

    if error_collector.hasErrors
      error_collector.showErrors
    end

    if @show_tokens
      tokenizer.tokens.each do |tok|
        puts "#{tok.get_line_number}| #{tok.to_s} #{tok.value}"
      end
    end

    parser = Parser.new(tokenizer.tokens, error_collector)
    parser.parse!

    if @show_ast
      parser.ast.to_string
      #parser.ast.print
    end

    if error_collector.hasErrors
      error_collector.showErrors
    end
  end
end
