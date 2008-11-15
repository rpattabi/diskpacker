
$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'review_session'

class TestReviewSession < Test::Unit::TestCase
  def setup
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
    assert_not_nil(@review_session)
  end
  
  def test_initialization
    assert_equal(1, @review_session.id)
    assert_equal(@implementor.name, @review_session.implementor.name)
    assert_equal(@reviewers.size, @review_session.reviewers.size)
    assert_equal(@comments.size, @review_session.comments.size)
  end
end
