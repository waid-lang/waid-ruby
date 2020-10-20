require_relative 'builder'
require_relative 'waid_exception'

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
    ensure
        puts "holi"
    end
end

main