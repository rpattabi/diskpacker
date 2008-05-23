require 'bin.rb'
require 'element.rb'

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
