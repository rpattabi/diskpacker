require 'bin.rb'
require 'element.rb'

require 'erb'
require 'iconv'

class InfraRecorderProjectGenerator
  attr_accessor :bin, :elements_input_paths

  def generate(file="divx_movies_#{@bin.id}.irp")
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
				<FileSize><%= (element.size*1024*1024).to_i %></FileSize>
<% end %>
			</File<%= idx %>>
<% idx += 1 %>
<% end %>
		</Data>
	</Project>
</InfraRecorder>    
    }
    
    title = "divx_movies_#{@bin.id}"
    elements = []
    
    @bin.elements.each do |e|
      elements << ElementWalker.new.walk(e)
    end
    
    elements.flatten!
    
    irp = File.open(file,'w')
    irp << ERB.new(irp_template, 0, '<>').result(binding)
    
#    # we need to convert the irp files with encoding utf-16
#    converter = Iconv.new("UTF-16","UTF-8")
#    puts irp.to_s
#    utf_16_str = converter.iconv(irp.to_s)
#    
#    File.open('/tmp/utf_16.irp','w') do |f|
#      f.puts utf_16_str
#    end
  end
end
