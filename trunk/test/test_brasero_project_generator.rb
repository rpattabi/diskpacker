# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require '../lib/disk_project_generators/brasero'
require 'tempfile'

class TestBraseroProjectGenerator < Test::Unit::TestCase
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
    
    brasero_generator = BraseroProjectGenerator.new
    brasero_generator.bin = dvd
    brasero_generator.elements_input_paths = ['/etc']
    
    out = Tempfile.new("tempfile")
    brasero_generator.generate(out.path)
    
    out_s = open(out.path) do |f|
      f.rewind
      f.read
    end
    
    expected_s = %q{<?xml version="1.0" encoding="UTF8"?>
<braseroproject>
	<version>0.2</version>
	<track>
		<data>
			<graft>
				<path>/directory</path>
				<uri>file:///etc/directory</uri>
			</graft>
		</data>
	</track>
</braseroproject>
    }
    
    assert_equal(expected_s,out_s)
  end
end
