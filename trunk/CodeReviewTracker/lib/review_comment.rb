
Severity = Struct.new( :UNDEFINED, :MINOR, :MAJOR )

class ReviewComment
  attr_accessor :comment, :severity, :at_file, :at_method, :at_line
  
  def initialize( comment, severity = :UNDEFINED, at_file = '', at_method = '', at_line = -1 )
    @comment, @severity, @at_file, @at_method, @at_line = 
    comment, severity, at_file, at_method, at_line
  end
end
