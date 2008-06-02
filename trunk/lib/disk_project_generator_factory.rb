# require everying under ./disk_project_generators directory
Dir.glob(File.join(File.dirname(__FILE__), './disk_project_generators/*.rb')).each {|f| require f }

class DiskProjectGeneratorFactory
  def create_generator(generator='brasero')
    generator_class = generator.split('_').collect{|w| w.capitalize}.join
    generator_class += "ProjectGenerator"
    
    Object.const_get(generator_class).new   
  end
end