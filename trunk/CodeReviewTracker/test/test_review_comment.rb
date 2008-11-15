
$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'review_comment'

class TestReviewComment < Test::Unit::TestCase
  def setup
    @review_comment = ReviewComment.new("misleading comments",
                                        :MINOR,
                                        'test.vb',
                                        'do_something',
                                        146
                                        )
  end
  
  def test_creation
    assert_not_nil(@review_comment, "ReviewComment creation failed")
  end
  
  def test_default_initialize
    a_comment = ReviewComment.new('dummy comment')
    assert_equal('dummy comment', a_comment.comment)
    assert_equal(:UNDEFINED, a_comment.severity)
    assert_equal('', a_comment.at_file)
    assert_equal('', a_comment.at_method)
    assert_equal(-1, a_comment.at_line)
  end
  
  def test_initialize
    assert_equal('misleading comments', @review_comment.comment)
    assert_equal(:MINOR, @review_comment.severity)
    assert_equal('test.vb', @review_comment.at_file)
    assert_equal('do_something', @review_comment.at_method)
    assert_equal(146, @review_comment.at_line)
  end
end
