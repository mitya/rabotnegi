require 'spec/spec_helper'

describe Salary do
  before :each do
    @between_1000_2000 = Salary.new(:min => 1000, :max => 2000)
    @above_1000 = Salary.new(:min => 1000)
    @below_1000 = Salary.new(:max => 1000)
    @exactly_1000 = Salary.new(:exact => 1000)
  end
  
  its "##new with one attribute just set it up" do
    actual = Salary.new(:exact => 1000) 
		expected = Salary.new
		expected.exact = 1000
		actual.should == expected  
  end
  
  its "##new with many attributes just sets them all" do
    actual = Salary.new(:min => 1000, :negotiable => false, :currency => :usd)
    expected = Salary.new
		expected.min = 1000
		expected.currency = :usd
		expected.negotiable = false
		actual.should == expected    
  end
  
  it "#parse exact values" do
    Salary.parse('1000').should == @exactly_1000
  end
  
  it "#parse max value" do
    Salary.parse('до 1000').should == @below_1000
    Salary.parse('<1000').should == @below_1000
  end
  
  it "#parse min value" do
    Salary.parse('от 1000').should == @above_1000
    Salary.parse('1000+').should == @above_1000
  end
  
  it "#parse min-max ranges" do
    Salary.parse('1000-2000').should == @between_1000_2000
  end
  
  its "#parse raise ArgumentError on any incorrect input" do
    lambda { Salary.parse('тыщща') }.should raise_error(ArgumentError)
  end
  
  its "#to_s formats salary" do
    @between_1000_2000.to_s.should == '1000—2000 р.'
  end
  
  its "#== treats salaries with the same attributes equal" do
    Salary.new(:exact => 1000, :currency => :usd).should == Salary.new(:exact => 1000, :currency => :usd)
  end
  
  its "#convert_currency changes salary value by CurrrencyConverter rates, and changes salary code" do
    source = Salary.new(:exact => 1000, :currency => :usd)
    target = source.convert_currency(:rub)
    
    target.exact.should == 25_000
    target.currency.should == :rub
    
    source.exact.should == 1000
    source.currency.should == :usd    
  end
    
  its "#convert_currency! does the same, but on self" do
    source = Salary.new(:exact => 1000, :currency => :usd)
    source.convert_currency!(:rub)
    
    source.exact.should == 25_000
    source.currency.should == :rub
  end
end