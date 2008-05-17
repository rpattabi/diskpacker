# 
# Bin Packer
# Ragunathan pattabi
# April 6th 2008
#

@@bin_id = 0

class Bin
  attr_accessor :id, :type, :capacity
  attr_reader :elements, :free_space
  
  def initialize(type='DVD4.7', capacity=4480)
    @elements = []
    
    @@bin_id += 1
    @id = @@bin_id
    
    @type, @capacity = type, capacity
    @free_space = capacity
  end
  
  def add_element(element)
    @elements << element
    @free_space -= element.size
  end
  
  def element_fit?(element)
    @free_space >= element.size 
  end
  
  def stored
    @capacity - @free_space
  end
  
  def clone
    clone = Bin.new
    clone.type, clone.capacity = @type, @capacity
    clone
  end
  
  def to_s
    output = "\n\nid = #{@id} :\n"
    output += "\tOccupied space = #{@capacity-@free_space} MB\n"
    output += "\tFree space = #{@free_space} MB\n"
    output += "\tContents :\n\t\t"
    
    es_to_s = @elements.collect { |e| e.to_s }
    output += es_to_s.join("\n\t\t")
  end
end

class Element
  attr_accessor :name, :size
  
  def initialize(name, size)
    @name, @size = name, size  
  end
  
  def to_s
    "#{@name}\t\tsize=#{@size} MB"
  end
end

class BinPacker
  attr_accessor :bins, :elements

  def initialize( bins, elements)
    @bins, @elements = bins, elements
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
          new_bin = @bins.last.clone
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
    
    output << "Total stored capacity : #{stored} MB\n"
    output << "Total wasted capacity : #{wasted} MB\n"
  end
end

require 'erb'
require 'iconv'

class InfraRecorderProjectGenerator
  attr_accessor :bin, :elements_input_paths

  def initialize(bin, elements_input_paths)
    @bin = bin
    @elements_input_paths = elements_input_paths
  end
  
  def generate_irp(file="divx_movies_#{@bin.id}.irp")
    irp_template = %q{<?xml version="1.0" encoding="utf-16" standalone="yes"?>
<InfraRecorder>
	<Project version="2" type="0" dvd="1">
		<Label><%= title %></Label>
		<ISO>
			<Level>0</Level>
			<CharSet>36</CharSet>
			<Format>0</Format>
			<Joliet enable="1">
				<LongNames>1</LongNames>
			</Joliet>
			<UDF>0</UDF>
			<RockRidge>1</RockRidge>
			<OmitVN>0</OmitVN>
		</ISO>
		<Fields>
			<Files>
			</Files>
		</Fields>
		<Boot>
			<BootCatalog>boot.catalog</BootCatalog>
		</Boot>
		<Data>
<% idx = 0 %>
<% elements.each do |element| %>
			<File<%= idx %> flags=<%= File.directory?(element.name) ? "\"1\"" : "\"0\"" %>>
<% path = "" %>
<% elements_input_paths.each do |input_path| %>
<% path = element.name.gsub(Regexp.new(input_path),"") %>
<% break if path != element.name %>
<% end %>
				<InternalName><%= path %></InternalName>
				<FullPath><%= element.name %></FullPath>
				<FileTime>128204264600000000</FileTime>
<% unless File.directory?(element.name) %>
				<FileSize><%= element.size %></FileSize>
<% end %>
			</File<%= idx %>>
<% idx += 1 %>
<% end %>
		</Data>
	</Project>
</InfraRecorder>    
    }
    
    title = "divx_movies_#{@bin.id}"
    elements_input_paths = @elements_input_paths
    bin = @bin
    elements = @bin.elements
    sub_elements = []
    
    elements.each do |element|
      if File.directory?(element.name)
        Find.find(element.name) do |path|
          sub_elements << Element.new(path, File.size(path)) unless path == element.name
        end
      end
    end
    
    elements += sub_elements
    elements.uniq!
    elements.sort! {|x,y| y.name <=> x.name}
    
    files = []
    folders = []
    
    elements.each do |element|
      if File.directory?(element.name)
        folders << element
      else
        files << element
      end
    end
    
    elements = folders + files
    
    irp = File.open(file,'w')
    irp << ERB.new(irp_template, 0, '<>').result(binding)
    
#    # we need to convert the irp files with encoding utf-16
#    converter = Iconv.new("UTF-16LE", "ISO-8859-1")
#    utf_16_str = converter.iconv(irp_proj_text)
#    
#    File.open(file,'w') do |f|
#      f.puts utf_16_str
#    end
  end
end

class K3bProjectGenerator
  attr_accessor :bin
  
  def initialize(bin)
    @bin = bin
  end
  
  def generate_k3b(file="divx_movies_#{@bin.id}.xml")
    k3b_template = %q{
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE k3b_dvd_project>
<k3b_dvd_project>
<general>
<writing_mode>auto</writing_mode>
<dummy activated="no"/>
<on_the_fly activated="no"/>
<only_create_images activated="no"/>
<remove_images activated="yes"/>
</general>
<options>
<rock_ridge activated="yes"/>
<joliet activated="yes"/>
<udf activated="no"/>
<joliet_allow_103_characters activated="yes"/>
<iso_allow_lowercase activated="no"/>
<iso_allow_period_at_begin activated="no"/>
<iso_allow_31_char activated="yes"/>
<iso_omit_version_numbers activated="no"/>
<iso_omit_trailing_period activated="no"/>
<iso_max_filename_length activated="no"/>
<iso_relaxed_filenames activated="no"/>
<iso_no_iso_translate activated="no"/>
<iso_allow_multidot activated="no"/>
<iso_untranslated_filenames activated="no"/>
<follow_symbolic_links activated="no"/>
<create_trans_tbl activated="no"/>
<hide_trans_tbl activated="no"/>
<iso_level>2</iso_level>
<discard_symlinks activated="no"/>
<discard_broken_symlinks activated="no"/>
<preserve_file_permissions activated="no"/>
<force_input_charset activated="no"/>
<do_not_cache_inodes activated="yes"/>
<input_charset>iso8859-1</input_charset>
<whitespace_treatment>noChange</whitespace_treatment>
<whitespace_replace_string>_</whitespace_replace_string>
<data_track_mode>auto</data_track_mode>
<multisession>auto</multisession>
<verify_data activated="yes"/>
</options>
<header>
<volume_id>divx_movies_#{@bin.id}</volume_id>
<volume_set_id/>
<volume_set_size>1</volume_set_size>
<volume_set_number>1</volume_set_number>
<system_id>LINUX</system_id>
<application_id>K3B THE CD KREATOR (C) 1998-2006 SEBASTIAN TRUEG AND THE K3B TEAM</application_id>
<publisher/>
<preparer/>
</header>
<files>
<% @bin.elements.each do |element| %>
<% file = element.name %>
<% unless File.directory?(file) %>
  <file name="<%= File.basename(file) %>">
    <url><%= file %></url>
  </file>
<% else %>
  <directory name="<%= file.split('/').last %>">
<% Find.find(file) do |path| %>
<% unless path == file %>
<%= ERB.new(file_recursive_template, 0, '<>').result(binding) %>
<% end %>
  </directory>
<% end %>
<file name="Ocean's Eleven.avi">
<url>/home/raguanu/Videos/movies/Ocean's Eleven.avi</url>
</file>
<file name="Ocean's Twelve.mpg">
<url>/home/raguanu/Videos/movies/Ocean's Twelve.mpg</url>
</file>
<file name="Scary Movie 4.mpg">
<url>/home/raguanu/Videos/movies/Scary Movie 4.mpg</url>
</file>
<file name="Shogun Assassin.avi">
<url>/home/raguanu/Videos/movies/Shogun Assassin.avi</url>
</file>
<file name="Shooter[2007].avi">
<url>/home/raguanu/Videos/movies/Shooter[2007].avi</url>
</file>
<file name="Supertroopers.avi">
<url>/home/raguanu/Videos/movies/Supertroopers.avi</url>
</file>
<file name="The Hitchhikers Guide to The Galaxy.avi">
<url>/home/raguanu/Videos/movies/The Hitchhikers Guide to The Galaxy.avi</url>
</file>
<file name="The Notebook.avi">
<url>/home/raguanu/Videos/movies/The Notebook.avi</url>
</file>
<file name="The Number 23.mpg">
<url>/home/raguanu/Videos/movies/The Number 23.mpg</url>
</file>
<file name="The.Bourne.Ultimatum.2007.DvD.XviD.Eng-FxM.avi">
<url>/home/raguanu/Videos/movies/The.Bourne.Ultimatum.2007.DvD.XviD.Eng-FxM.avi</url>
</file>
<file name="The.Last.Samurai.TS.SVCD-MPT.DIVX_Xtech.avi">
<url>/home/raguanu/Videos/movies/The.Last.Samurai.TS.SVCD-MPT.DIVX_Xtech.avi</url>
</file>
<file name="The_Counterfeiter.avi">
<url>/home/raguanu/Videos/movies/The_Counterfeiter.avi</url>
</file>
<file name="Transformers[2007].TS.Eng.DivX-LTT.avi">
<url>/home/raguanu/Videos/movies/Transformers[2007].TS.Eng.DivX-LTT.avi</url>
</file>
<file name="Troy.avi">
<url>/home/raguanu/Videos/movies/Troy.avi</url>
</file>
</directory>
</files>
</k3b_dvd_project>
    }
  end
end

bins = []
bins << Bin.new

elements = []

require 'find'

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

bin_packer = BinPacker.new(bins, elements)
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