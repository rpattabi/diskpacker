require 'review_session'

class ReviewItem
  attr_accessor :id, :review_sessions
  
  def initialize(id=0)
    @id = id
    @review_sessions = []
  end
  
end
