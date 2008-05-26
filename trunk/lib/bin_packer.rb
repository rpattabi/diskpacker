require 'bin.rb'
require 'element.rb'

class BinPacker
  attr_accessor :bins, :elements

  def initialize( bin_factory, elements)
    @bin_factory, @elements = bin_factory, elements
    @bins = []
    @bins << bin_factory.create_bin
  end
  
  def best_fit(output_file="bin_packed.txt")
    unless @elements.empty?
      # Sort in descending order
      @elements.sort! { |a,b| b.size <=> a.size }
    end
    
    # Loop through each Element and place in a Bin
    @elements.each do |element|
      if @bins.first.capacity >= element.size 
        is_element_in_bin = false

        # Sort the bin with ascending free space
        @bins.sort! { |a,b| a.free_space <=> b.free_space }

        # add the element to the bin with least free space if it fits
        @bins.each do |bin|
          if bin.element_fit?(element)
            bin.add_element(element)
            is_element_in_bin = true
            break
          end
        end

        # if the element didn't fit in any existing bin, create a new bin and add it there
        unless is_element_in_bin
          new_bin = @bin_factory.create_bin
          @bins << new_bin

          if new_bin.capacity >= element.size
            new_bin.add_element(element)
          else
            skipped << element
          end
        end
      end
    end
    
    output = File.open(output_file, 'w')
    output << @bins.to_s + "\n"
    output << "Total number of disks : #{@bins.size}\n"
    
    stored = 0
    wasted = 0
    @bins.each do |bin|
      stored += bin.stored
      wasted += bin.free_space
    end
    
    output << "Total stored capacity : #{(stored/1024/1024).to_i} MB\n"
    output << "Total wasted capacity : #{(wasted/1024/1024).to_i} MB\n"
  end
end
