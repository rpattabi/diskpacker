require 'bin.rb'
require 'element.rb'

class BinPacker
  attr_accessor :bins, :elements, :skipped

  def initialize( bin_factory, elements)
    @bin_factory, @elements = bin_factory, elements
    @bins = []
    @skipped = []
    @bins << bin_factory.create_bin
  end
  
  def best_fit()
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
           @skipped << element
          end
        end
      else
        @skipped << element
      end
    end
    
    #fix the bin ids
    id = 0
    @bins.each do |bin|
      bin.id = id
      id += 1
    end
    
    @bins
  end  
end
