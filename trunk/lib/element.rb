
class Element
  attr_accessor :name, :size
  
  def initialize(name, size)
    @name, @size = name, size  
  end
  
  def to_s
    @name
  end
  
  def to_s_windows
    @name.gsub(/\//,"\\")
  end
  
  def <=>(rhs)
    self.name.downcase <=> rhs.name.downcase
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
    @elements.flatten.sort
  end
end