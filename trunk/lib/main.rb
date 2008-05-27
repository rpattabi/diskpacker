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

def collect_input_paths(file='input_paths.txt')
  input_paths = []
  File.open(file,'r').readlines.each do |input_path|
    if input_path && input_path.strip != ''
      input_path = input_path.strip.gsub(/\\/,"/") ## converts windows style c:\temp paths to c:/temp
      input_paths << input_path if File.directory?(input_path)
    end
  end
  
  input_paths
end

def generate_delete_batch(bins)
  # generate batch file to delete the files
  bins.each do |bin|
    file = File.open("delete_backup_set_#{bin.id}.bat",'w')
    bin.elements.each do |e|
      file << "del /P /F \"#{e.name}\"\n" if File.directory?(e.name)
    end
  end
end

def generate_elements(input_paths)
  elements = []
  root_elements = element_generator(input_paths)
  root_elements.each do |root|
    elements << root.elements
  end

  elements.flatten
end

def pack_bins(bin_factory,elements)
  bin_packer = BinPacker.new(bin_factory, elements)
  bin_packer.best_fit()  # returns bins
end

def generate_irp(bins,input_paths)
  irp_generator = InfraRecorderProjectGenerator.new
  irp_generator.elements_input_paths = input_paths

  bins.each do |bin|
    irp_generator.bin = bin
    irp_generator.generate()
  end  
end

input_paths = collect_input_paths('input_paths.txt')
elements = generate_elements(input_paths)

bin_factory = BinFactory.new(:DVD4_7)
bins = pack_bins(bin_factory,elements)
bins_report(bins)

generate_irp(bins,input_paths)
generate_delete_batch(bins)