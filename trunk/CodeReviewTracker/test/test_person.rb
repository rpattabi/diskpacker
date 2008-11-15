
$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'person'

class TestPerson < Test::Unit::TestCase
  def setup
    @person = Person.new('rpattabi', :REVIEWER)
  end
  
  def test_creation
    assert_not_nil(@person)
  end
  
  def test_initialize
    assert_equal('rpattabi', @person.name)
    assert_equal(:REVIEWER, @person.role)
  end
end
