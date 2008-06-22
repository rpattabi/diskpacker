$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require '../lib/disk_project_generators/k3b'
require 'input_builder'
require 'tempfile'

require 'rubygems'
require 'flexmock/test_unit'

class TestK3bProjectGenerator < Test::Unit::TestCase
  include FlexMock::TestCase

  def setup
    @input_info = InputInfo.new
    @input_info.input_paths = ['/etc']
    flexmock(File).should_receive(:directory?).and_return{|f| f.match(/\./) ? false : true}
  end
  
  def test_generate
    # get the bin ready first
    dvd_bin_factory = BinFactory.new(:DVD4_7)
    dvd = dvd_bin_factory.create_bin
    
    e = Element.new('/etc/directory/file.ext',2000/1024.0)
    ee = Element.new('/etc/directory/sub/file2.ext',2000/1024.0)
    ce = CompositeElement.new('/etc/directory',4000/1024.0)
    cce = CompositeElement.new('/etc/directory/sub',2000/1024.0)
    
    ce << e
    cce << ee
    ce << cce

    dvd.add_element(ce)
    
    # generate irp for this bin
    
    k3b_generator = K3bProjectGenerator.new
    k3b_generator.bin = dvd
    k3b_generator.input_info = @input_info
    
    out = Tempfile.new("tempfile")
    k3b_generator.generate("BACKUP",out.path)
    
    out_s = open(out.path) do |f|
      f.rewind
      f.read
    end
    
    expected_s = %q{<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE k3b_data_project>
<k3b_data_project>
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
<volume_id>BACKUP_0</volume_id>
<volume_set_id/>
<volume_set_size>1</volume_set_size>
<volume_set_number>1</volume_set_number>
<system_id>LINUX</system_id>
<application_id>DiskPacker (c) 2008</application_id>
<publisher/>
<preparer/>
</header>
<files>
<directory name="directory"><file name="file.ext"><url>/etc/directory/file.ext</url></file><directory name="sub"><file name="file2.ext"><url>/etc/directory/sub/file2.ext</url></file></directory></directory></files>
</k3b_data_project>
}
    
    assert_equal(expected_s,out_s)
  end
end
