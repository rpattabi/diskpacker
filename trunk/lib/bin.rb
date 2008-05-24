require 'element.rb'

class Bin
  attr_accessor :id, :type, :capacity
  attr_reader :elements, :free_space
  @@bin_id = 0

  def initialize(type='DVD4.7', capacity=4480)
    @elements = []
    
    @@bin_id += 1
    @id = @@bin_id
    
    @type, @capacity = type, capacity
    @free_space = capacity
  end
  
  def add_element(element)
    @elements << element
    @free_space -= element.size
  end
  
  def element_fit?(element)
    @free_space >= element.size 
  end
  
  def stored
    @capacity - @free_space
  end
  
  def to_s
    output = "\n\nid = #{@id} :\n"
    output += "\tOccupied space = #{@capacity-@free_space} MB\n"
    output += "\tFree space = #{@free_space} MB\n"
    output += "\tContents :\n\t\t"
    
    es_to_s = @elements.collect { |e| e.to_s }
    output += es_to_s.join("\n\t\t")
  end
end

class BinFactory
  def initialize(type=DVD4_9)
    @type = type
    
    if @type == DVD4_9
      @capacity = 4480
    elsif @type == CDR
      @capacity = 700
    else
      raise "disk type not supported."
    end    
  end
  
  def create_bin()     
    Bin.new(@type.to_s,@capacity)
  end
end