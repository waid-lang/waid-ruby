require_relative 'common/error_collector'
require_relative 'common/waid_exception'
require_relative 'common/file_util'
require_relative 'tokenizer/tokenizer'
require_relative 'parser/parser'
require_relative 'interpreter/enviroment'
require_relative 'interpreter/interpreter'

# El Builder es el responsable de juntar todas las piezas del compilador e
# interpretador. El builder se encarga pasarle los tokens del tokenizador al
# parser, y el AST del parser al interpretador.
#
# Este también maneja todas las opciones del cli usadas para el debug como la
# impresión de los tokens generados o la impresión del árbol sintáctico del
# programa.

class Builder
  attr_writer :source_path
  def initialize()
    @show_tokens = false
    @show_ast = false
    @show_env = false
    @source_path = String.new
  end

  # Pseudo setters

  def set_show_tokens
    @show_tokens = true
  end

  def set_show_ast
    @show_ast = true
  end

  def set_show_env
    @show_env = true
  end

  # Función principal llamada en main
  def run

    # Creamos un objeto archivo
    source_file = WaidFile.new(@source_path)

    # error_colector es la única instancia que se crea de ErrorCollector. Esta
    # se va a pasar a cada fase del compilador para que... recolecte errores.
    error_collector = ErrorCollector.new(source_file)

    # tokenizer es la única instancia de tokenizer.
    tokenizer = Tokenizer.new(source_file, error_collector)
    tokenizer.tokenize!

    # Si se generaron errores en la fase de análisis léxico, mostrarlos.
    if error_collector.hasErrors
      error_collector.showErrors
    end

    # Si se seleccionó la opción en la cli, mostramos los tokens junto al
    # número de linea en donde aparecen.
    if @show_tokens
      tokenizer.tokens.each do |tok|
        puts "#{tok.get_line_number}| #{tok.to_s} #{tok.value}"
      end
      puts
    end

    # parser es la única instancia de Parser
    parser = Parser.new(tokenizer.tokens, error_collector)
    parser.parse!
  
    # Mostramos es AST generado si es que el usuario seleccionó la opción.
    if @show_ast
      #parser.ast.to_string
      parser.ast.print_tree("", true)
      puts
    end
    
    # Y mostramos los errores generados durante el análisis sintáctico.
    if error_collector.hasErrors
      error_collector.showErrors
    end

    # Creamos un nuevo intérprete e interpretamos el AST
    interpreter = Interpreter.new(parser.ast, error_collector, false)
    interpreter.run

   # Prefiero implementar esto después
    # Mostramos el estado final del Env
    if @show_env
      puts " \nEnviroment:"

      # Mostramos las variables
      if not interpreter.env.records.empty?
        puts "Global variables"
        puts "----------------"
        interpreter.env[0].memory_map.each do |k, v|
          puts "#{k} => #{v.inspect}"
        end
      end
    end
  end
end
