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

######## Nueva implementación ########

class RuntimeStack
  def initialize
    @records = Array.new
  end

  def records
    @records
  end

  def getTopMost
    @records[@records.length - 1]
  end

  def define(name, val)
    getTopMost.define(name, val)
    val
  end

  def resolveName(name)
    value = getTopMost.getName(name)
    if not value
      value = @records[0].getName(name)
    end
    value
  end

  def push(activation_record)
    @records.push(activation_record)
  end

  def pop
    @records.delete_at(@records.length - 1)
  end

  def pp
    puts "CallStack"
  end
end

class StackFrame
  attr_reader :identifier, :memory_map
  def initialize(id=nil, p=nil)
    @identifier = id
    @previous = p
    @memory_map = Hash.new
  end

  def getName(name)
    value = getLocalName(name)
    if not value and @previous
      value = @previous.getLocalName(name)
    end
    value
  end

  def getLocalName(name)
    @memory_map[name]
  end

  def define(name, object)
    @memory_map[name] = object
  end

  def getAllNames
    @memory_map.keys
  end

  def linkedTo
    @previous
  end

  def makeLinkTo(activation_record)
    @previous = activation_record
    self
  end
end
