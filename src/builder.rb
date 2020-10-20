require_relative 'error_collector'
require_relative 'waid_exception'
require_relative 'file_util'
require_relative 'tokenizer'

class Builder
    attr_writer :source_path
    def initialize(debug=false)
        @show_tokens = false
        @show_ast = false
        @source_path = String.new
        @debug = debug
    end

    def set_show_tokens
        @show_tokens = true
    end

    def set_show_ast
        @show_ast = true
    end

    def run
        error_collector = ErrorCollector.new

        source_file = WaidFile.new(@source_path)

        tokenizer = Tokenizer.new(source_file, @debug, error_collector)
        tokenizer.tokenize

        if error_collector.has_errors
            error_collector.show_errors
        end

        if @show_tokens
            tokenizer.tokens.each do |tok|
                puts "#{tok.get_line_number}| #{tok.to_s} #{tok.value}"
            end
        end
    end
end