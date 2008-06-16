# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'bin_packer'
require 'tempfile'

class TestBinPacker < Test::Unit::TestCase
  def setup   
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
    
    @dvd_factory = BinFactory.new(:DVD4_7)
    @bin_packer = BinPacker.new
    @elements = walker_root.elements
  end
  
  def test_bin_packer_simple
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
    
    bin_packer = BinPacker.new
    result = bin_packer.best_fit(@dvd_factory,walker_root.elements)
    assert_equal(1,result.packed_bins.size)
    assert_equal([d,df1,dd,ddf1,d1,d1f1,rf1],result.packed_bins.first.elements)
    assert_equal(0,result.skipped_elements.size)
  end
  
  def test_packing
    result = @bin_packer.best_fit(@dvd_factory,@elements)
    
    assert_equal(1,result.packed_bins.size)
    assert_equal(7,result.packed_bins.first.elements.size)
        
    total_size = 0
    result.packed_bins.first.elements.each do |e|
      total_size += e.size unless e.name.scan(/\./).empty? #consider only the files
    end
    
    assert_equal(9000,total_size)
   
    a = result.packed_bins.first.elements.collect do |e|
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
  
  def test_skipped_basic    
    biggie = Element.new('/etc/file.ext',10000000000000)
    
    result = @bin_packer.best_fit(@dvd_factory, [biggie])
    assert_equal(1,result.skipped_elements.size)
    assert_equal([biggie],result.skipped_elements)
  end
  
  def test_skipped_mixed
    rf1 = Element.new('/etc/file.ext',2000)
    d = CompositeElement.new('/etc/directory',40000000000000)
    df1 = Element.new('/etc/directory/dir_file.ext',20000000000000)
    dd = CompositeElement.new('/etc/directory/sub',20000000000000)    
    ddf1 = Element.new('/etc/directory/sub/dir_sub_file.ext',20000000000000)
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
    
    result = @bin_packer.best_fit(@dvd_factory,walker_root.elements)        
    assert_equal(4, result.skipped_elements.size)
    assert_equal([d,df1,dd,ddf1],result.skipped_elements)
  end
end
