
Role = Struct.new( :REVIEWER, :IMPLEMENTOR, :TESTER, :MANAGER)

class Person
  attr_accessor :name, :role
  
  def initialize(name, role)
    @name, @role = name, role
  end
end
