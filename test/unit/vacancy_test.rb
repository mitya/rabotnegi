# coding: utf-8

require 'test_helper'

unit_test Vacancy do
  setup do
    @vacancy = Vacancy.new    
  end
  
  test 'default salary' do
    assert @vacancy.salary.negotiable?
  end
  
  test "salary_text=" do
    vacancy = Vacancy.new(salary: Salary.make(exact: 1000))
    assert_equal Salary.make(exact: 1000), vacancy.salary
    vacancy.salary_text = "от 5000"
    assert_equal Salary.make(min: 5000), vacancy.salary
    assert_equal 5000, vacancy.salary_min
    assert_equal nil, vacancy.salary_max
  end
  
  # test "search" do
  #   make :vacancy, :title => "An AutoCAD engineer"
  #   make :vacancy, :description => "somebody who knows AutoCAD"
  #   
  #   results = Vacancy.search(:q => "autocad")
  #   p results
  # end
end
