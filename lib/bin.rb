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
  
  def to_s_windows
    output = "\n\nid = #{@id} :\n"
    output += "\tOccupied space = #{((@capacity-@free_space)/1024/1024).to_i} MB\n"
    output += "\tFree space = #{(@free_space/1024/1024).to_i} MB\n"
    output += "\tContents :\n\t\t"
    
    es_to_s = self.elements.collect { |e| e.to_s_windows }
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

class BinsReport
  attr_accessor :bins
  
  def initialize(bins)
    @bins = bins
  end
    
  def report(path="", report_name="bin_packed")
    path = fix_path(path)
    
    # windows
    output_windows = File.open(path+report_name+"_windows.txt",'w')
    # linux
    output_linux = File.open(path+report_name+"_linux.txt",'w')
    
    stored = 0
    wasted = 0
    @bins.each do |bin|
      stored += bin.stored
      wasted += bin.free_space
    end

    output_windows << @bins.collect { |bin| bin.to_s_windows }.to_s + "\n"
    output_linux << @bins.to_s + "\n"

    [output_windows,output_linux].each do |output|
      output << "\n\nTotal number of disks : #{@bins.size}\n"  
      output << "Total stored capacity : #{(stored/1024/1024).to_i} MB\n"
      output << "Total wasted capacity : #{(wasted/1024/1024).to_i} MB\n"
    end
  end
  
  def generate_delete_script(path="", script_name="delete_backup_set")
    path = fix_path(path)
    
    @bins.each do |bin|
        output_windows = File.open(path+script_name+"_#{bin.id}.bat",'w')
        output_linux = File.open(path+script_name+"_#{bin.id}.sh",'w')
        #File.chmod(0100, path+script_name+"_#{bin.id}.sh") #make the file executable

        bin.elements.each do |e|
          if File.directory?(e.name)
            output_windows << "del /P /F /S \"#{e.to_s_windows}\"\n"
            output_linux << "rm --recursive --verbose -I \"#{e.to_s}\"\n"
          else
            output_windows << "del /P /F \"#{e.to_s_windows}\"\n"
            output_linux << "rm --verbose -I \"#{e.to_s}\"\n"            
          end
        end    
    end
  end
  
  private 
  def fix_path(path="")
      unless path == ""
        path.strip!
        path = path+'/' unless path.scan(/\/|\\$/)
      end
      path
  end  
end
