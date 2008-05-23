
class Element
  attr_accessor :name, :size
  
  def initialize(name, size)
    @name, @size = name, size  
  end
  
  def to_s
    "#{@name}\t\tsize=#{@size} MB"
  end
end
