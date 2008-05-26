
class Element
  attr_accessor :name, :size
  
  def initialize(name, size)
    @name, @size = name, size  
  end
  
  def to_s
    @name
  end
  
  def <=>(rhs)
    self.name <=> rhs.name
  end
end

class CompositeElement < Element
  attr_accessor :elements
  
  def initialize(name,size)
    @name, @size = name, size
    @elements = []
  end
  
  def <<(e)
    @elements << e
  end
  
  def size
    total = 0
    @elements.flatten.each do |e|
      total += e.size
    end
    total
  end
end

class ElementWalker  
  def initialize
    @elements = []
  end
  
  def walk(root_element)
    if root_element.class == Element
      @elements << root_element
    else    
      root_element.elements.each do |e|
        @elements << e
        if e.class == CompositeElement
          walk e
        end
      end
    end
  end
  
  def elements
    @elements.flatten.sort {|a,b| a.name <=> b.name}
  end
end