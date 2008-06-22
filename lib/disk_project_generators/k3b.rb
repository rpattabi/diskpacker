require 'bin'
require 'element'

require 'erb'
require 'iconv'

class K3bProjectGenerator
  attr_accessor :bin, :input_info, :output_path
  
  def initialize
    @output_path = ''
    @temp_tree = ''
  end  
  
  def generate(name="BACKUP", file=@output_path + "k3b_#{name}_#{@bin.id}.xml")
    k3b_template = %q{<?xml version="1.0" encoding="UTF-8"?>
<% type = @bin.type.to_s.match(/dvd/) ? 'dvd' : 'data' %>
<!DOCTYPE k3b_<%= type %>_project>
<k3b_<%= type %>_project>
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
<verify_data activated="no"/>
</options>
<header>
<volume_id><%= "#{name}_#{@bin.id}" %></volume_id>
<volume_set_id/>
<volume_set_size>1</volume_set_size>
<volume_set_number>1</volume_set_number>
<system_id>LINUX</system_id>
<application_id>DiskPacker (c) 2008</application_id>
<publisher/>
<preparer/>
</header>
<files>
<% @bin.elements.each do |element| %>
<% walk_the_element_tree(element) %>
<% end %>
<%= @temp_tree %>
</files>
</k3b_<%= type %>_project>
}
    
    element_walker = ElementWalker.new
    @temp_tree = ''

    project = File.open(file,'w')
    project << ERB.new(k3b_template, 0, '<>').result(binding)
    project.close()
  end
  
  def walk_the_element_tree(element)
    unless File.directory?(element.name)
      @temp_tree += "<file name=\"#{File.basename(element.name)}\"><url>#{element.name}</url></file>"
    else
      @temp_tree += "<directory name=\"#{element.name.split('/').last}\">"
      element.elements.each do |e|
        walk_the_element_tree(e)
      end
      @temp_tree += "</directory>"
    end
  end    
end
