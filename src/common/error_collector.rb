require_relative 'waid_exception'

# Función auxiliar para calcular el número de dígitos de un número. Esto lo
# usamos para que la impresión de errores quede bonita :)
def number_of_digits(num)
  Math.log10(num + 1).ceil
end

CompilationError = Struct.new(:error_description, :source_position) do
  def to_s
    # Ya que implementaré estos mensajes de error en el futuro, me quedo satisfecho con unos más simples.
    # Modelos de errores
    # Ni siquiera sé si son errores reales, pero sirven para mostrar la estructura:
    # 
    # main.vt
    #     Error: Unknown identifier 'retrn'
    #     23| square: func(x: int): int => retrn !math::pow(x, 2);
    #                                      ^~~~~
    #     Error: Expected ')' before ':'
    #     97| chType: generic<OR, NW> func(or: OR[]: NW[] =>
    #                                              ^
    # core.vt
    #     Error: 'reset_token()' takes exactly 1 argument (2 given)
    #     15|     token_arr@[i] => !->reset_token(token_arr@[i], x_coord - 2);
    #                                                            ^~~~~~~~~~~
    error_string = "Error: #{error_description}\n\t#{source_position.line}| #{full_line}\n\t"
    error_string += " " * (source_position.column + number_of_digits(source_position.line) + 1) + "^"
  end
end

# ErrorCollector recolecta todos los errores en todas las fases del compilador.
# También se encarga de imprimirlos bonitos en caso de.
class ErrorCollector
  def initialize(source)

    # errors = Array<CompilationError>
    @errors = Array.new

    # Este es el único lugar en el que se guardará el archivo completo.
    # Digo "será" porque todavía no lo es :(
    @source_file = source
  end

  # addError: CompilationError -> nil
  def addError(comp_error)
    @errors.push(comp_error)
  end

  # hasErrors: nil -> bool
  def hasErrors
    not @errors.empty?
  end

  def formatError(c_err)
    full_line = getLine(c_err.source_position)
    error_string = "Error: #{c_err.error_description}\n\t#{c_err.source_position.line}| #{full_line}\n\t"
    error_string += " " * (c_err.source_position.column + number_of_digits(c_err.source_position.line) + 1) + "^"
  end

  # showErrors muestra los errores uno por uno. Eso xd
  def showErrors
    # Primero mostramos el nombre del archivo
    puts @source_file.get_filename

    # Y luego los errores
    @errors.each do |err|
      puts "\t#{formatError(err)}"
    end

    # Luego lanzamos un error para que el "rescue" en waid.rb lo atrape y se
    # termine la ejecución del programa. ¿Ingenioso? No. Pero funciona.
    raise WaidError.new("#{@errors.size} #{@errors.size > 1? 'errors' : 'error'}", "Waid")
  end
  
  # getLine: SourcePosition -> String
  # getLine devuelve la linea representada por sp
  def getLine(sp)
    line_start = sp.source_line_column
    line = String.new
    while @source_file[line_start] and not @source_file[line_start].eql? "\n"
      line += @source_file[line_start]
      line_start += 1
    end
    line
  end
end
