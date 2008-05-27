# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'bin_packer'
require 'tempfile'

class TestBinPacker < Test::Unit::TestCase
  def prepare_bin
    dvd_factory = BinFactory.new(:DVD4_7)
    
    rf1 = Element.new('/etc/file.ext',2000)
    d = CompositeElement.new('/etc/directory',4000)
    df1 = Element.new('/etc/directory/dir_file.ext',2000)
    dd = CompositeElement.new('/etc/directory/sub',2000)    
    ddf1 = Element.new('/etc/directory/sub/dir_sub_file.ext',2000)
    d1 = CompositeElement.new('/etc/directory1',3000)
    d1f1 = Element.new('/etc/directory1/dir1_file.ext',3000)
    
    root = CompositeElement.new('/etc',9000)
    root << rf1
    dd << ddf1
    d1 << d1f1
    d << df1
    d << dd
    root << d
    root << d1
    
    walker_root = ElementWalker.new
    walker_root.walk(root)
    
    BinPacker.new(dvd_factory,walker_root.elements)    
  end
  
  def test_bin_packer_creation
    dvd_factory = BinFactory.new(:DVD4_7)
    
    rf1 = Element.new('/etc/file.ext',2000)
    d = CompositeElement.new('/etc/directory',4000)
    df1 = Element.new('/etc/directory/dir_file.ext',2000)
    dd = CompositeElement.new('/etc/directory/sub',2000)    
    ddf1 = Element.new('/etc/directory/sub/dir_sub_file.ext',2000)
    d1 = CompositeElement.new('/etc/directory1',3000)
    d1f1 = Element.new('/etc/directory1/dir1_file.ext',3000)
    
    root = CompositeElement.new('/etc',9000)
    root << rf1
    dd << ddf1
    d1 << d1f1
    d << df1
    d << dd
    root << d
    root << d1
    
    walker_root = ElementWalker.new
    walker_root.walk(root)
    
    bin_packer = BinPacker.new(dvd_factory,walker_root.elements)
    assert_equal(1,bin_packer.bins.size)
    assert_equal([d,df1,dd,ddf1,d1,d1f1,rf1],bin_packer.elements)
  end
  
  def test_packing
    bin_packer = prepare_bin
    bin_packer.best_fit()
    
    assert_equal(1,bin_packer.bins.size)
    assert_equal(7,bin_packer.bins.first.elements.size)
        
    total_size = 0
    bin_packer.bins.first.elements.each do |e|
      total_size += e.size unless e.name.scan(/\./).empty? #consider only the files
    end
    
    assert_equal(9000,total_size)
   
    a = bin_packer.bins.first.elements.collect do |e|
      e.name
    end
    
    assert_equal([
      '/etc/directory',
      '/etc/directory/dir_file.ext',
      '/etc/directory/sub',
      '/etc/directory/sub/dir_sub_file.ext',
      '/etc/directory1',
      '/etc/directory1/dir1_file.ext',
      '/etc/file.ext'
    ],a)
  end
end
