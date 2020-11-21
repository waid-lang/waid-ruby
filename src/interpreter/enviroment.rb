class Enviroment
  def initialize
    @table = Hash.new
    @outer = nil
  end

  def table
    @table
  end

  # Devuelve el WaidObject asociado a key
  def get(key)
    object = @table[key]
    if not object and @outer
      object = @outer.get(key)
    end
    object
  end

  # Asocia object a key en el ambiente
  def set(key, object)
    @table[key] = object
    object
  end

  # Devuelve el outer env
  def Outer
    @outer
  end
end
