
$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'review_item'

class TestReviewItem < Test::Unit::TestCase
  def setup
    @review_item = ReviewItem.new(100000)
    
    @implementor = Person.new('skumar2', :IMPLEMENTOR)
    @reviewers = [Person.new('rpattabi', :REVIEWER)]
    @comments = [ReviewComment.new(
        "misleading comments",
        :MINOR,
        'test.vb',
        'do_something',
        146)]
    
    @review_session = ReviewSession.new(1, @implementor, @reviewers, @comments)    
  end
  
  def test_creation
    assert_not_nil(@review_item)
  end
  
  def test_initialize   
    assert_equal(100000, @review_item.id)
    
    @review_item.review_sessions << @review_session
    assert_equal(1, @review_item.review_sessions.size)
  end
end
