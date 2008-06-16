require 'bin'
require 'disk_project_generator_factory'

class OutputBuilder
    
  def build_report(packer_result, path="", report_name="bin_packed")
    path = fix_path(path)
    
    # windows
    output_windows = File.open(path+report_name+"_windows.txt",'w')
    # linux
    output_linux = File.open(path+report_name+"_linux.txt",'w')
    
    stored = 0
    wasted = 0
    packer_result.packed_bins.each do |bin|
      stored += bin.stored
      wasted += bin.free_space
    end

    output_windows << packer_result.packed_bins.collect { |bin| bin.to_s_windows }.to_s + "\n"
    output_linux << packer_result.packed_bins.to_s + "\n"

    [output_windows,output_linux].each do |output|
      output << "\n\n--------------------------------------------------------------------------------\n"
      output << "Total number of disks : #{packer_result.packed_bins.size}\n"  
      output << "Total stored capacity : #{(stored/1024/1024).to_i} MB\n"
      output << "Total wasted capacity : #{(wasted/1024/1024).to_i} MB\n"
      output << "--------------------------------------------------------------------------------\n"
      
      output << "\nSkipped Files and Folders: "
      output << "none" if packer_result.skipped_elements.empty?
      output << "\n"
    end
    
    # skipped elements info
    output_windows << packer_result.skipped_elements.collect{|e| "\t" + e.to_s_windows + "\n"}.to_s + "\n"
    output_linux << packer_result.skipped_elements.collect{|e| "\t" + e.to_s + "\n"}.to_s + "\n"
  end
  
  def build_delete_script(packer_result, path="", script_name="delete_backup_set")
    path = fix_path(path)
    
    packer_result.packed_bins.each do |bin|
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
  
  def build_disk_burning_projects(packer_result, input_info, path="", project_name="BACKUP")
    project_generator_factory = DiskProjectGeneratorFactory.new

    generators = []
    ['brasero','infra_recorder'].each do |g|
      generator = project_generator_factory.create_generator(g)
      generators << generator
    end

    packer_result.packed_bins.each do |bin|
      generators.each do |generator|
        generator.bin = bin
        generator.input_info = input_info
        generator.generate(project_name)
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
