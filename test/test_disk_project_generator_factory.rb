
$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'disk_project_generator_factory'

class TestDiskProjectGeneratorFactory < Test::Unit::TestCase
  def test_create_brasero
    brasero_generator = DiskProjectGeneratorFactory.new.create_generator('brasero')
    assert_not_equal(nil,brasero_generator)
    assert_equal(BraseroProjectGenerator,brasero_generator.class)
  end
  
  def test_create_invalid
    assert_raise(NameError) { DiskProjectGeneratorFactory.new.create_generator('junk') }
  end
  
  def test_create_infrarecorder
    infra_generator = DiskProjectGeneratorFactory.new.create_generator('infra_recorder')
    assert_not_equal(nil,infra_generator)
    assert_equal(InfraRecorderProjectGenerator,infra_generator.class)
  end
end
