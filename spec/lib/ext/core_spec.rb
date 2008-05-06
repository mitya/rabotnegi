require 'spec/spec_helper'

describe Object do
  its "#in? determines if self is included in list; list is vararg" do
    1.in?([1, 2, 3]).should == true
    1.in?([3, 4, 5]).should == false
    1.in?(1, 2, 3).should == true
  end
end