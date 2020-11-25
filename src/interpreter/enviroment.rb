class Enviroment
  def initialize(outer=nil)
    @table = Hash.new
    @outer = outer
  end

  def table
    @table
  end

  # Devuelve el WaidObject asociado a key
  def get(key)
    object = getLocal(key)
    if not object and @outer
      object = @outer.getLocal(key)
    end
    object
  end

  def getLocal(key)
    @table[key]
  end

  def getGlobal(key)
    object = getLocal(key)
    if not object and @outer
      object = @outer.getGlobal(key)
    end
    object
  end

  # Asocia object a key en el ambiente
  def set(key, object)
    @table[key] = object
    object
  end

  def setArrayObject(id, index, value)
    # Este es el medio hack siono
    @table[id].Values[index] = value
  end

  # Devuelve el outer env
  def Outer
    @outer
  end
end
