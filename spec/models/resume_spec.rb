require 'spec/spec_helper'

describe Resume do
  before :each do
    @resume = Resume.new
  end
  
  its "#name format is like 'First Last" do
    Resume.new(:fname => 'Mitya').name.should == 'Mitya'
    Resume.new(:fname => 'Mitya', :lname => 'Ivanov').name.should == 'Mitya Ivanov'
  end
  
  its "#summary format is like 'name — position (salary)" do
    vasya = Resume.new(:fname => 'Вася', :lname => 'Иванов', :job_title => 'Java программист', :min_salary => '30000')
    vasya.summary.should == "Вася Иванов — Java программист (от 30000 р.)"
  end
end