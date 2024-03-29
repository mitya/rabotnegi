require 'test_helper'

unit_test CurrencyConverter do
  test "convertion" do
    assert_in_delta 71, CurrencyConverter.convert(100, :usd, :eur), 1
    assert_equal 1, CurrencyConverter.convert(25, :rub, :usd)
  end
  
  test "convertion to the same currency" do
    assert_equal 100, CurrencyConverter.convert(100, :usd, :usd)
    assert_equal 100, CurrencyConverter.convert(100, :rub, :rub)
  end
end