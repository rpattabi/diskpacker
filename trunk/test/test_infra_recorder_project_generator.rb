# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require '../lib/disk_project_generators/infrarecorder'
require 'tempfile'

class TestInfraRecorderProjectGenerator < Test::Unit::TestCase
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
    
    irp_generator = InfraRecorderProjectGenerator.new
    irp_generator.bin = dvd
    irp_generator.elements_input_paths = ['/etc']
    
    out = Tempfile.new("tempfile")
    irp_generator.generate(out.path)
    
    out_s = open(out.path) do |f|
      f.rewind
      f.read
    end
    
    expected_s = %q{<?xml version="1.0" encoding="utf-16" standalone="yes"?>
<InfraRecorder>
	<Project version="3" type="0" dvd="1">
		<Label>BACKUP_0</Label>
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
			<File0 flags="0">
				<InternalName>/directory</InternalName>
				<FullPath>/etc/directory</FullPath>
				<FileTime>128204264600000000</FileTime>
				<FileSize>3</FileSize>
			</File0>
			<File1 flags="0">
				<InternalName>/directory/file.ext</InternalName>
				<FullPath>/etc/directory/file.ext</FullPath>
				<FileTime>128204264600000000</FileTime>
				<FileSize>1</FileSize>
			</File1>
			<File2 flags="0">
				<InternalName>/directory/sub</InternalName>
				<FullPath>/etc/directory/sub</FullPath>
				<FileTime>128204264600000000</FileTime>
				<FileSize>1</FileSize>
			</File2>
			<File3 flags="0">
				<InternalName>/directory/sub/file2.ext</InternalName>
				<FullPath>/etc/directory/sub/file2.ext</FullPath>
				<FileTime>128204264600000000</FileTime>
				<FileSize>1</FileSize>
			</File3>
		</Data>
	</Project>
</InfraRecorder>    
    }
    
    assert_equal(expected_s,out_s.gsub!(/\000/,''))
  end
  
#  def test_to_be_removed
#    dvd_bin_factory = BinFactory.new(:DVD4_7)
#    dvd = dvd_bin_factory.create_bin
#
#    ce = CompositeElement.new('C:/',2563)
#    ce1 = CompositeElement.new('C:/downloads',2000/1024.0)
#    ce2 = CompositeElement.new('E:/temp/BLK',2000/1024.0)
#    
#    e1 = Element.new('E:/temp/ATPResults1stRun.xls',39424)
#    e2 = Element.new('E:/temp/BLK/CatalogMigration.log',31798)
#    
#    ce2 << e2
#    
#    ce << e1
#    ce << ce1
#    ce << ce2
#    
#    dvd.add_element(ce)
#    
#    # generate irp for this bin
#    
#    irp_generator = InfraRecorderProjectGenerator.new
#    irp_generator.bin = dvd
#    irp_generator.elements_input_paths = ['C:','E:/temp']
#    
#    #out = Tempfile.new("tempfile")
#    irp_generator.generate('c:/temp/result.irp')#out.path)    
#  end
end
