require 'spec/spec_helper'

describe CurrencyConverter do
  it "##converts currencies" do
    CurrencyConverter.convert(100, :usd, :eur).should == 73
    CurrencyConverter.convert(25, :rub, :usd).should == 1
  end
  
  its "##convert doen't do anything when source and target currencies are equal" do
    CurrencyConverter.convert(100, :usd, :usd).should == 100
    CurrencyConverter.convert(100, :rub, :rub).should == 100    
  end
end