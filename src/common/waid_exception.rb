class WaidError < StandardError
  attr_reader :msg
  def initialize(msg, prefix="Error")
    @msg = make_message(msg, prefix)
    super(msg)
  end

  def make_message(m, p)
    puts "#{p}: #{m}"
  end
end
