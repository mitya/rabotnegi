require 'spec/spec_helper'

describe Employer do
  before :each do
    @microsoft =  Employer.new(:name=>'Microsoft', :login => 'ms',
      :password => '123', :password_confirmation => '123')
  end
  
  it "is created in valid state" do
    @microsoft.should be_valid
  end
  
  its "##new requires password confirmation to create valid object" do
    @bad_microsoft = Employer.new(:name=>'Microsoft', :login => 'ms', :password => '123')
    @bad_microsoft.should_not be_valid
    @bad_microsoft.errors.should be_invalid(:password_confirmation)
  end    
end