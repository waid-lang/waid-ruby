require_relative 'src/builder'
require_relative 'src/common/waid_exception'

require 'optparse'

def main

    @options = {}
    OptionParser.new do |op|
        op.banner += ' filename'

        op.on("-t", "--show-tokens", "Print the tokens produced by the scanner") do
            @options[:show_tokens] = true
        end
    end.parse!

    # NO SÉ SI ESTA ES LA MANERA CORRECTA DE HACERLO EN RUBY PERDÓN
    if ARGV.empty?
        puts optparse
        exit(-1)
    end
    file = ARGV.pop

    begin
        builder = Builder.new

        if @options[:show_tokens]
            builder.set_show_tokens
        end
        builder.source_path = file
        builder.run
    rescue WaidError => error
        print error.msg
    end
end

main