require 'bin'
require 'element'

require 'erb'
require 'iconv'

$KCODE = "UTF8"

class InfraRecorderProjectGenerator
  attr_accessor :bin, :elements_input_paths

  def generate(file="BACKUP_#{@bin.id}.irp")
    irp_template = %q{<?xml version="1.0" encoding="utf-16" standalone="yes"?>
<InfraRecorder>
	<Project version="3" type="0" dvd="1">
		<Label><%= title %></Label>
		<FileSystem>
			<Identifier>0</Identifier>
		</FileSystem>
		<ISO>
			<Level>0</Level>
			<Format>0</Format>
			<DeepDirs>1</DeepDirs>
			<Joliet enable="1">
				<LongNames>1</LongNames>
			</Joliet>
			<OmitVerNum>0</OmitVerNum>
		</ISO>
		<Fields>
			<Files>
			</Files>
		</Fields>
		<Boot>
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
				<FileSize><%= (element.size).to_i %></FileSize>
<% end %>
			</File<%= idx %>>
<% idx += 1 %>
<% end %>
		</Data>
	</Project>
</InfraRecorder>    
    }
    
    title = "BACKUP_#{@bin.id}"
    elements = []
    
    walker = ElementWalker.new
    @bin.elements.each do |e|
        elements << e 
        walker.walk(e) if e.class == CompositeElement
    end
    
    elements << walker.elements
    elements.flatten!.sort!
    
    irp = File.open(file,'w')
    irp << ERB.new(irp_template, 0, '<>').result(binding)
    irp.close
    
    # we need to convert the irp files with encoding utf-16
    
    irp_to_s = open(file) do |f| 
      f.rewind
      f.read
    end
    
    # Need to strip leading and trailing spaces
    # These cause the utf-8 to utf-16le conversion to fail in windows
    # But works fine in linux
    irp_to_s_stripped = ""
    irp_to_s.split("\n").each do |line|
      irp_to_s_stripped += line.strip
    end
    
    open(file,'w') do |f| 
      f.write Iconv.new("UTF-16LE", "UTF-8").iconv(irp_to_s_stripped)
    end
  end
end