require 'person'
require 'review_comment'

class ReviewSession
  attr_accessor :id, :implementor, :reviewers, :comments
  
  def initialize(id, implementor, reviewers, comments=[])
    @id, @implementor, @reviewers, @comments = id, implementor, reviewers, comments
  end
end
