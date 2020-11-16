# WaidError representa un error en Waid, obviamente
class WaidError < StandardError
  attr_reader :msg
  def initialize(msg, prefix="Error")
    @msg = make_message(msg, prefix)
    super(msg)
  end

  # Esto imprime el mensaje de error con su prefijo correspondiente
  def make_message(m, p)
    puts "#{p}: #{m}"
  end
end
