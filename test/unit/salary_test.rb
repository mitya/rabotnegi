require 'test_helper'

unit_test Salary do
  def setup
    @between_1000_2000 = Salary.make(:min => 1000, :max => 2000)
    @above_1000 = Salary.make(:min => 1000)
    @below_1000 = Salary.make(:max => 1000)
    @exactly_1000 = Salary.make(:exact => 1000)
  end
  
  test "creation with one attribute" do
    actual = Salary.make(:exact => 1000)
		expected = Salary.make; expected.exact = 1000
		assert_equal expected, actual
  end
  
  test "creation with many attributes" do
    actual = Salary.make(:min => 1000, :negotiable => false, :currency => :usd)
    expected = Salary.make; expected.min = 1000; expected.currency = :usd; expected.negotiable = false
		assert_equal expected, actual    
  end
  
  test "parsing of exact value" do
    assert_equal @exactly_1000, Salary.parse('1000')
  end
  
  test "parsing of max value" do
    assert_equal @below_1000, Salary.parse('<1000')
    assert_equal @below_1000, Salary.parse('до 1000')
  end
  
  test "parsing of min value" do
    assert_equal @above_1000, Salary.parse('от 1000')
    assert_equal @above_1000, Salary.parse('1000+')
  end
  
  test "parsing of ranges" do
    assert_equal @between_1000_2000, Salary.parse('1000-2000')
  end

  test "parsing with bad input" do
    assert_equal Salary.new, Salary.parse('тыщща')
  end
  
  test "formatting" do
    assert_equal '1000—2000 р.', @between_1000_2000.to_s
  end
  
  test "equality" do
    assert_equal Salary.make(:exact => 1000, :currency => :usd), Salary.make(:exact => 1000, :currency => :usd)
  end
  
  test "currency convertion" do
    salary = Salary.make(:exact => 1000, :currency => :usd)
    salary.convert_currency(:rub)
    
    assert_equal 25_000, salary.exact
    assert_equal :rub, salary.currency
  end
end