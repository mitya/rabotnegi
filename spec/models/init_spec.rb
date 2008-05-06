require 'spec/spec_helper'

describe 'Domain Initialization' do
  it "loads at least some industry data" do
    $industry_map.size.should > 10
    $popular_industry_table.size.should > 5
    $other_industry_table.size.should > 5
  end
  
  it "loads 5 cities data" do
    $city_table.size.should == 5
    $city_map.size.should == 5    
  end
  
  its "$industry_list contains all industries from $industry_metadata_table" do
    $industry_metadata_table.length.should == $industry_list.length
    $industry_metadata_table.each { |code,| $industry_list.should_include(code) }
  end
  
  it "industry tables are sorted from A-Z" do
    column_is_alphabetized! $popular_industry_table, 1
    column_is_alphabetized! $other_industry_table, 1
  end
  
  disabled_visual_test do
    print_variable '$industry_map'
    print_variable '$popular_industry_table'
    print_variable '$other_industry_table'
  end
  
private
  def column_is_alphabetized!(table, col)
    prev = ''
    table.each do |row|
      cur = row[col]
      cur.should >= prev
      prev = cur
    end
  end
  
  def print_variable(variable_name)
    puts "\n#{variable_name} ="
    pp eval(variable_name)
  end
end