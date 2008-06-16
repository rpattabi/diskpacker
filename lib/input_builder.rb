require 'element'
require 'find'
  
$KCODE = 'UTF8'

class InputBuilder
  attr_accessor :input_paths, :input_elements
  
  def initialize(input_file='input_paths.txt')
    @input_paths = collect_input_paths(input_file)
    @input_elements = generate_elements(@input_paths)
  end

  private
  
  def collect_input_paths(file)
    input_paths = []
    
    File.open(file,'r').readlines.each do |input_path|
      if input_path && input_path.strip != ''
        input_path = input_path.strip.gsub(/\\/,"/") ## converts windows style c:\temp paths to c:/temp
        input_paths << input_path if File.directory?(input_path)
      end
    end

    input_paths
  end

  def generate_elements(input_paths)
    elements = []
    root_elements = element_generator(input_paths)
    root_elements.each do |root|
      elements << root.elements
    end

    elements.flatten
  end  

  def dir_tree_walker(input_path, &block)
    result = yield(input_path)

    if File.directory?(input_path)
      Find.find(input_path) do |path|
        if path != input_path && File.dirname(path) == input_path
            result << dir_tree_walker(path,&block)
        end
      end
    end

    result
  end

  def element_generator(input_paths)
    root_elements = []

    input_paths.each do |input_path| 
        root_elements << dir_tree_walker(input_path) do |f|
          if File.directory?(f)
            CompositeElement.new(f, File.size(f)*1024.0)
          else
            Element.new(f, File.size(f))
          end
        end
    end

    root_elements
  end
end