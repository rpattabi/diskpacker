require 'bin'
require 'element'

require 'erb'
require 'iconv'

class K3bProjectGenerator
  attr_accessor :bin
  
  def generate(file="divx_movies_#{@bin.id}.xml")
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
