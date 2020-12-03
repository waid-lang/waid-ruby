require_relative 'waid_exception'

# WaidFile representa un archivo fuente de Waid. Este contiene información del
# path del archivo y los índices del inicio de cada línea.
class WaidFile
  attr_accessor :line_indexes
  def initialize(path)

    # Si el archivo en el path no existe, lanzamos un error y que el rescue en
    # "waid.rb" lo atrape
    if not File.exist?(path)
      puts "File '#{File.basename(path)}' doesn't exist."
      puts
      raise WaidError.new("1 error", "Waid")
    end
    @file_path = path
    @source = File.read(path)
    @line_indexes = Array.new.push(0)
  end

  # getFilename devuelve el nombre del archivo.
  def get_filename
    File.basename(@file_path)
  end

  def getPath
    File.dirname(File.expand_path(@file_path))
  end

  # TODO: quitar esto! El archivo completo solo debería exisitir en
  # ErrorCollector :((
  def [](i)
    @source[i]
  end

  def source
    @source
  end
end
