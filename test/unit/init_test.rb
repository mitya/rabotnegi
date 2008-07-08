require 'test_helper'

unit_test "Domain initialization" do
  test "industry data loading" do
    assert $industry_map.size > 10
    assert $popular_industry_table.size > 5
    assert $other_industry_table.size > 5    
  end
  
  test "city data loading" do
    assert $city_table.size == 5
    assert $city_map.size == 5    
  end
  
  test "$industry_list contains all industries from $industry_metadata_table" do
    assert $industry_metadata_table.length == $industry_list.length
    assert $industry_metadata_table.all? { |code,| $industry_list.include?(code) }
  end
  
  test "industry tables sorting" do
    column_is_alphabetized! $popular_industry_table, 1
    column_is_alphabetized! $other_industry_table, 1
  end
  
  visual_test "print tables" do
    print_variable '$industry_map'
    print_variable '$popular_industry_table'
    print_variable '$other_industry_table'
  end
  
  def column_is_alphabetized!(table, col)
    prev = ''
    table.each do |row|
      cur = row[col]
      assert cur >= prev
      prev = cur
    end
  end
  
  def print_variable(variable_name)
    puts "\n#{variable_name} ="
    pp eval(variable_name)
  end
end