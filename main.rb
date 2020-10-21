require_relative 'src/builder'
require_relative 'src/common/waid_exception'

def main
    return if ARGV.length < 1
    file = ARGV.[](0) # Probando sintaxis solamente

    begin
        builder = Builder.new(true)
        builder.set_show_tokens
        builder.source_path = file
        builder.run
    rescue WaidError => error
        puts error.msg
    end
end

main