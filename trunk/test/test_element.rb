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
  
  def test_element_to_s_windows
    e = Element.new('/etc/netbeans.conf',2000)
    assert_equal("\\etc\\netbeans.conf",e.to_s_windows)

    e1 = Element.new('/etc\netbeans.conf',2000)
    assert_equal("\\etc\\netbeans.conf",e.to_s_windows)
  end
end

class TestCompositeElement < Test::Unit::TestCase
  def test_composite_element_creation
    ce = CompositeElement.new('/etc/directory',0)
    assert_equal('/etc/directory',ce.name)
    assert_equal(0,ce.size)
    assert_equal(0,ce.elements.size)    
  end
  
  def test_insert_element
    e = Element.new('/etc/file.ext',2000)
    ce = CompositeElement.new('/etc/directory',4000)
   
    ce << e
    assert_equal(1,ce.elements.size)
    assert_equal('/etc/file.ext',ce.elements.first.name)
    assert_equal(2000,ce.elements.first.size)
    assert_equal(2000,ce.size)
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
    assert_equal(4000,ce.size)
  end
end

class TestElementWalker < Test::Unit::TestCase
  def test_simple_element_walk
    e = Element.new('/etc/file/ext',2000)
    walker = ElementWalker.new
    walker.walk(e)
    assert_equal([e],walker.elements)
  end
  
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
  
  def test_longer_walk
    
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
    assert_equal([d,df1,dd,ddf1,d1,d1f1,rf1],walker_root.elements)
  end
  
  def test_rubyish_walk
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

    collected_elements = []
    expected_elements = [root,rf1,d,df1,dd,ddf1,d1,d1f1]
    
    walker_root.walk_with_block(root) { |item| collected_elements << item }
    assert_equal(expected_elements.length,collected_elements.length) #redundant check. But useful in case of errors.
    assert_equal(expected_elements,collected_elements)
  end
end