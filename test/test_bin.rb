require 'test/unit'
require 'bin'

class TestBinFactory < Test::Unit::TestCase
  def test_create_dvd_bin
    dvd_bin_factory = BinFactory.new(:DVD4_7)
    dvd = dvd_bin_factory.create_bin
    assert_equal(Bin,dvd.class)
    assert_equal(:DVD4_7,dvd.type)
    assert_equal(4480,dvd.capacity)
  end
  
  def test_create_cdr_bin
    cdr_bin_factory = BinFactory.new(:CDR)
    cdr = cdr_bin_factory.create_bin
    assert_equal(Bin,cdr.class)
    assert_equal(:CDR,cdr.type)
    assert_equal(700,cdr.capacity)
  end
  
  def test_create_bad_bin
    assert_raise(RuntimeError) { BinFactory.new(:BAD) }
  end
end

class TestBin < Test::Unit::TestCase
  def test_simple_bin
    cdr_bin_factory = BinFactory.new(:CDR)
    cdr = cdr_bin_factory.create_bin
    
    e = Element.new('/etc/netbeans.conf',2000/1024.0)
    cdr.add_element(e)
    
    assert_equal(700-2000/1024.0,cdr.free_space)
    assert_equal(2000/1024.0,cdr.stored)
    
    small = Element.new('etc/small.txt', 5)
    assert_equal(true,cdr.element_fit?(small))
    
    biggie = Element.new('etc/big.bang', 700 )
    assert_equal(false,cdr.element_fit?(biggie))
    
    correct = Element.new('etc/correct.png', 700-2000/1024.0)
    assert_equal(true,cdr.element_fit?(correct))
  end
  
  def test_add_elements
    dvd_bin_factory = BinFactory.new(:DVD4_7)
    dvd = dvd_bin_factory.create_bin
    
    e = Element.new('/etc/file.ext',2000/1024.0)
    ee = Element.new('/etc/sub/file2.ext',2000/1024.0)
    ce = CompositeElement.new('/etc/directory',4000/1024.0)
    cce = CompositeElement.new('/etc/directory/sub',2000/1024.0)
    
    ce << e
    cce << ee
    ce << cce

    dvd.add_element(ce)
    assert_equal([ce],dvd.elements)
  end
end
