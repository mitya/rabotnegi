require 'spec/spec_helper'

describe Vacancy do
  before :each do
    @vacancy = Vacancy.new    
  end
  
  its 'default salary is negotiable' do
    @vacancy.salary.negotiable?.should == true    
  end
end