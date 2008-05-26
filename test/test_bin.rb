require 'test/unit'
require 'bin'

class TestBinFactory < Test::Unit::TestCase
  def test_create_dvd_bin
    dvd_bin_factory = BinFactory.new(:DVD4_7)
    dvd = dvd_bin_factory.create_bin
    assert_equal(Bin,dvd.class)
    assert_equal(:DVD4_7,dvd.type)
    assert_equal(4480*1024*1024,dvd.capacity)
  end
  
  def test_create_cdr_bin
    cdr_bin_factory = BinFactory.new(:CDR)
    cdr = cdr_bin_factory.create_bin
    assert_equal(Bin,cdr.class)
    assert_equal(:CDR,cdr.type)
    assert_equal(700*1024*1024,cdr.capacity)
  end
  
  def test_create_bad_bin
    assert_raise(RuntimeError) { BinFactory.new(:BAD) }
  end
  
  def test_bin_id
    dvd_bin_factory = BinFactory.new(:DVD4_7)
    dvd0 = dvd_bin_factory.create_bin
    dvd1 = dvd_bin_factory.create_bin
    dvd2 = dvd_bin_factory.create_bin
    dvd3 = dvd_bin_factory.create_bin
    dvd4 = dvd_bin_factory.create_bin
    
    assert_equal([0,1,2,3,4],[dvd0.id,dvd1.id,dvd2.id,dvd3.id,dvd4.id])
    
    cdr_bin_factory = BinFactory.new(:CDR)
    cdr0 = cdr_bin_factory.create_bin
    cdr1 = cdr_bin_factory.create_bin
    cdr2 = cdr_bin_factory.create_bin
    cdr3 = cdr_bin_factory.create_bin
    cdr4 = cdr_bin_factory.create_bin
    
    assert_equal([0,1,2,3,4],[cdr0.id,cdr1.id,cdr2.id,cdr3.id,cdr4.id])
    
  end
end

class TestBin < Test::Unit::TestCase
  def test_simple_bin
    cdr_bin_factory = BinFactory.new(:CDR)
    cdr = cdr_bin_factory.create_bin
    
    e = Element.new('/etc/netbeans.conf',2000)
    cdr.add_element(e)
    
    assert_equal(700*1024*1024-2000,cdr.free_space)
    assert_equal(2000,cdr.stored)
    
    small = Element.new('etc/small.txt', 5)
    assert_equal(true,cdr.element_fit?(small))
    
    biggie = Element.new('etc/big.bang', 700*1024*1024 )
    assert_equal(false,cdr.element_fit?(biggie))
    
    correct = Element.new('etc/correct.png', 700*1024*1024-2000)
    assert_equal(true,cdr.element_fit?(correct))
  end
  
  def test_add_elements
    dvd_bin_factory = BinFactory.new(:DVD4_7)
    dvd = dvd_bin_factory.create_bin
    
    e = Element.new('/etc/file.ext',2000)
    ee = Element.new('/etc/sub/file2.ext',2000)
    ce = CompositeElement.new('/etc/directory',4000)
    cce = CompositeElement.new('/etc/directory/sub',2000)
    
    ce << e
    cce << ee
    ce << cce

    dvd.add_element(ce)
    assert_equal([ce],dvd.elements)
  end
end
