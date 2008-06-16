require 'bin'
require 'element'

class BinPacker
  def best_fit( bin_factory, elements)  
    result = PackerResult.new
    result.packed_bins << bin_factory.create_bin #just add empty bin
    
    unless elements.empty?
      # Sort in descending order
      elements.sort! { |a,b| b.size <=> a.size }
    end
    
    # Loop through each Element and place in a Bin
    elements.each do |element|
      if result.packed_bins.first.capacity >= element.size 
        is_element_in_bin = false

        # Sort the bin with ascending free space
        result.packed_bins.sort! { |a,b| a.free_space <=> b.free_space }

        # add the element to the bin with least free space if it fits
        result.packed_bins.each do |bin|
          if bin.element_fit?(element)
            bin.add_element(element)
            is_element_in_bin = true
            break
          end
        end

        # if the element didn't fit in any existing bin, create a new bin and add it there
        unless is_element_in_bin
          new_bin = bin_factory.create_bin
          result.packed_bins << new_bin

          if new_bin.capacity >= element.size
            new_bin.add_element(element)
          else
           result.skipped_elements << element
          end
        end
      else
        result.skipped_elements << element
      end
    end
    
    #fix the bin ids
    id = 0
    result.packed_bins.each do |bin|
      bin.id = id
      id += 1
    end
    
    result
  end
end

class PackerResult
  attr_accessor :packed_bins, :skipped_elements
  
  def initialize
    @packed_bins = []
    @skipped_elements = []
  end
end
