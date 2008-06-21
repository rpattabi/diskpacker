require 'bin'
require 'element'

require 'erb'

$KCODE = "UTF8"

class BraseroProjectGenerator
  attr_accessor :bin, :input_info, :output_path
  
  def initialize
    @output_path = ''
  end  
  
  def generate(name="BACKUP", file=@output_path+"brasero_#{name}_#{@bin.id}.xml")
    brasero_template = %q{<?xml version="1.0" encoding="UTF8"?>
<braseroproject>
	<version>0.2</version>
	<track>
		<data>
<% bin.elements.each do |element| %>
<% path0 = "" %>
<% elements_input_paths.each do |input_path| %>
<% path0 = element.name.gsub(Regexp.new(input_path),"") %>
<% break if path0 != element.name %>
<% end %>
			<graft>
				<path><%= path0 %></path>
				<uri>file://<%= element.name %></uri>
			</graft>
<% end %>
		</data>
	</track>
</braseroproject>
    }
    
    bin = @bin
    elements_input_paths = @input_info.input_paths
    
    project = File.open(file,'w')
    project << ERB.new(brasero_template, 0, '<>').result(binding)
    project.close()
  end
end