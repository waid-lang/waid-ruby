class Enviroment
  attr_reader :env
  def initialize(e=Hash.new, o=nil)
    @env = Hash.new
    @outer = o
  end

  def get(name)
    if @env.key?(name)
      return @env[name]
    end
    nil
  end

  def set(name, obj)
    @env[name] = obj
    obj
  end 
end

def newInnerEnv(outer)
  return Enviroment.new(o: outer)
end
