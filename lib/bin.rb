require 'element.rb'

class Bin
  attr_accessor :id, :type, :capacity
  attr_reader :free_space

  def initialize(id=0, type=:DVD4_7, capacity=4480*1024)
    @elements = []
    
    @id = id
    @type, @capacity = type, capacity
    @free_space = capacity
  end
  
  def add_element(element)
    @elements << element
    @free_space -= element.size
    
    raise "bin overloaded" if @free_space < 0
  end
  
  def element_fit?(element)
    @free_space >= element.size 
  end
  
  def stored
    @capacity - @free_space
  end
  
  def elements
    @elements.flatten.sort
  end
  
  def to_s
    output = "\n\nid = #{@id} :\n"
    output += "\tOccupied space = #{((@capacity-@free_space)/1024/1024).to_i} MB\n"
    output += "\tFree space = #{(@free_space/1024/1024).to_i} MB\n"
    output += "\tContents :\n\t\t"
    
    es_to_s = self.elements.collect { |e| e.to_s }
    output += es_to_s.join("\n\t\t")
  end
end

class BinFactory
  def initialize(type=:DVD4_7)
    @id = 0
    @type = type
    
    if @type == :DVD4_7
      @capacity = 4480*1024*1024
    elsif @type == :CDR
      @capacity = 700*1024*1024
    else
      raise "disk type not supported."
    end    
  end
  
  def create_bin()
    bin = Bin.new(@id,@type,@capacity)
    @id += 1
    bin
  end
end

def bins_report(bins, output_file="bin_packed.txt")
  output = File.open(output_file, 'w')

  stored = 0
  wasted = 0
  bins.each do |bin|
    stored += bin.stored
    wasted += bin.free_space
  end

  output << bins.to_s + "\n"  
  output << "\n\nTotal number of disks : #{bins.size}\n"  
  output << "Total stored capacity : #{(stored/1024/1024).to_i} MB\n"
  output << "Total wasted capacity : #{(wasted/1024/1024).to_i} MB\n"    
end
