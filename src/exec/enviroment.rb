class Enviroment
  attr_reader :Objects, :Functions
  def initialize(e=Hash.new)
    @Objects = e
    @Functions = Hash.new
  end

  def get(name)
    if @Objects.key?(name)
      return @Objects[name]
    elsif @Functions.key?(name)
      return @Functions[name]
    end
    nil
  end

  def set_ob(name, obj)
    @Objects[name] = obj
    obj
  end 

  def set_func(name, func)
    @Functions[name] = func
    func
  end
end

def newInnerEnv
  return Enviroment.new
end
