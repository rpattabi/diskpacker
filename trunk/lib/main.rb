require 'bin.rb'
require 'element.rb'
require 'bin_packer.rb'
require 'disk_project_generators/infrarecorder.rb'
require 'disk_project_generators/k3b.rb'

require 'find'

$KCODE = 'UTF8'

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

input_paths = []
File.open('input_paths.txt','r').readlines.each do |input_path|
  input_path.strip!
  input_paths << input_path  if File.directory?(input_path)
end

elements = []
root_elements = element_generator(input_paths)
root_elements.each do |root|
  elements << root.elements
end

elements.flatten!

bin_factory = BinFactory.new(:DVD4_7)
bin_packer = BinPacker.new(bin_factory, elements)
bin_packer.best_fit()

irp_generator = InfraRecorderProjectGenerator.new
irp_generator.elements_input_paths = input_paths

bin_packer.bins.each do |bin|
  irp_generator.bin = bin
  irp_generator.generate()
  
  # generate batch file to delete the files
  file = File.open("delete_backup_set_#{bin.id}.bat",'w')
  bin.elements.each do |e|
    file << "del /P /F \"#{e.name}\"\n" if File.directory?(e.name)
  end
end