require 'bin.rb'
require 'element.rb'
require 'bin_packer.rb'
require 'disk_project_generators/infrarecorder.rb'
require 'disk_project_generators/k3b.rb'

require 'find'

bin_factory = BinFactory.new.create_bin(DVD4_9)

elements = []

h = {}
input_paths = []

File.open('input_paths.txt','r').readlines.each do |input_path|
  input_path.strip!
  input_paths << input_path
  
  Find.find(input_path) do |path|
    if File.directory?(path) and path != input_path
      size = 0
      Find.find(path) do |path2|
        size += File.size(path2)
      end
      h[path] = size unless size == 0
      Find.prune
    elsif File.dirname(path) == input_path
      h[path] = File.size(path) unless File.size(path) == 0
    end
  end
end

h.each do |key,val|
  puts "file:#{key}\t\tsize:#{val/1024/1024}MB\n"
  elements << Element.new(key,val/1024/1024)
end 

bin_packer = BinPacker.new(bin_factory, elements)
bin_packer.best_fit()

irp_generator = InfraRecorderProjectGenerator.new(bin_packer.bins.first, input_paths)
#irp_generator.generate_irp()

bin_packer.bins.each do |bin|
  irp_generator.bin = bin
  irp_generator.generate_irp()
  
  # generate batch file to delete the files
  file = File.open("divx_movies_#{bin.id}.bat",'w')
  bin.elements.each do |e|
    file << "del /P /F \"#{e.name}\"\n" if File.directory?(e.name)
  end
end