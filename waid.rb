#!/usr/bin/env ruby

require_relative 'src/builder'
require_relative 'src/common/waid_exception'

require 'optparse'

def main
  @options = {}
  optparser = OptionParser.new do |op|
    op.banner += ' filename'
    op.on("-t", "--show-tokens", "Print the tokens produced by the scanner") do
      @options[:show_tokens] = true
    end

    op.on("-a", "--show-ast", "Print the AST produced by the parser") do
      @options[:show_ast] = true
    end

    op.on("-e", "--show-final-env", "Print the final state of the global enviroment") do
      @options[:show_env] = true
    end
  end

  optparser.parse!
  # NO SÉ SI ESTA ES LA MANERA CORRECTA DE HACERLO EN RUBY PERDÓN
  if ARGV.empty?
    puts optparser
    exit(-1)
  end
  file = ARGV.pop

  begin
    builder = Builder.new

    if @options[:show_tokens]
      builder.set_show_tokens
    end

    if @options[:show_ast]
      builder.set_show_ast
    end

    if @options[:show_env]
      builder.set_show_env
    end

    builder.source_path = file
    builder.run
  rescue WaidError => error
    print error.msg
  end
end

main
