require 'test/unit'
require 'element'

class TestElement < Test::Unit::TestCase
  def test_element_creation
    e = Element.new('/etc/netbeans.conf',2000)
    assert_equal('/etc/netbeans.conf',e.name)
    assert_equal(2000,e.size)
  end
  
  def test_element_to_s
    e = Element.new('/etc/netbeans.conf',2000)
    assert_equal("/etc/netbeans.conf",e.to_s)
  end
end

class TestCompositeElement < Test::Unit::TestCase
  def test_composite_element_creation
    ce = CompositeElement.new('/etc/directory',4000)
    assert_equal('/etc/directory',ce.name)
    assert_equal(4000,ce.size)
    assert_equal(0,ce.elements.size)    
  end
  
  def test_insert_element
    e = Element.new('/etc/file.ext',2000)
    ce = CompositeElement.new('/etc/directory',4000)
   
    ce << e
    assert_equal(1,ce.elements.size)
    assert_equal('/etc/file.ext',ce.elements.first.name)
    assert_equal(2000,ce.elements.first.size)
  end
  
  def test_insert_composite_element
    e = Element.new('/etc/file.ext',2000)
    ee = Element.new('/etc/sub/file2.ext',2000)
    ce = CompositeElement.new('/etc/directory',4000)
    cce = CompositeElement.new('/etc/directory/sub',2000)
    
    ce << e
    cce << ee
    ce << cce

    assert_equal(2,ce.elements.size)
    assert_equal(1,cce.elements.size)
    assert_equal('/etc/directory',ce.name)
    assert_equal('/etc/directory/sub',ce.elements.last.name)
    assert_equal('/etc/sub/file2.ext',ce.elements.last.elements.first.name)
  end
end

class TestElementWalker < Test::Unit::TestCase
  def test_walk    
    e = Element.new('/etc/file.ext',2000)
    ee = Element.new('/etc/sub/file2.ext',2000)
    ce = CompositeElement.new('/etc/directory',4000)
    cce = CompositeElement.new('/etc/directory/sub',2000)

    ce << e
    cce << ee
    ce << cce

    walker_cce = ElementWalker.new
    walker_cce.walk(cce)
    assert_equal([ee],walker_cce.elements)
    
    walker_ce = ElementWalker.new
    walker_ce.walk(ce)
    assert_equal([cce,e,ee],walker_ce.elements) 
  end
end