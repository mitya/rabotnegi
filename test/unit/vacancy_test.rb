require 'test_helper'

unit_test Vacancy do
  def setup
    @vacancy = Vacancy.new    
  end
  
  test 'default salary' do
    assert @vacancy.salary.negotiable?
  end
end