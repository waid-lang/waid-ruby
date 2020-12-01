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
    #puts "\tDEFINING  #{name} => #{val.inspect}"
    getTopMost.define(name, val)
    val
  end

  def resolveName(name)
    value = getTopMost.getName(name)
    if not value
      # Globals
      value = @records[0].getName(name)
    end
    value
  end

  def push(activation_record)
    #puts "PUSHING #{activation_record.identifier}"
    @records.push(activation_record)
  end

  def pop
    #puts "POPPING #{@records[@records.length - 1].identifier}"
    @records.delete_at(@records.length - 1)
  end

  def isReturnState
    getTopMost.return_flag
  end

  def setReturnState
    getTopMost.setReturnState
  end

  def pp
    puts "CallStack"
  end
end

class StackFrame
  attr_reader :identifier, :memory_map
  attr_accessor :return_flag
  def initialize(id, p=nil)
    @identifier = id
    @previous = p
    @return_flag = false
    @memory_map = Hash.new
  end

  def getName(name)
    value = getLocalName(name)
    if not value and @previous
      value = @previous.getLocalName(name)
    end
    value
  end

  def setReturnState
    @return_flag = true
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
