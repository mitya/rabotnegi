require 'test_helper'

unit_test Resume do
  def setup
    @resume = Resume.new
  end
  
  test "name format" do
    assert_equal 'Mitya', Resume.new(:fname => 'Mitya').name
    assert_equal 'Mitya Ivanov', Resume.new(:fname => 'Mitya', :lname => 'Ivanov').name
  end
  
  test "summary format" do
    vasya = Resume.new(:fname => 'Вася', :lname => 'Иванов', :job_title => 'Java программист', :min_salary => '30000')
    assert_equal "Вася Иванов — Java программист (от 30000 р.)", vasya.summary
  end
end