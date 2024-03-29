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
  
  test "search" do
    v_text_in_title = make Vacancy, title: "An AutoCAD engineer"
    v_text_in_description = make Vacancy, description: "somebody who knows AutoCAD"
    v_no_match = make Vacancy
    
    results = Vacancy.search(q: "autocad")
    assert results.include?(v_text_in_title)
    assert results.include?(v_text_in_description)
    assert !results.include?(v_no_match)
  end
  
  test "==" do
    assert_not_equal Vacancy.new, nil
    assert_not_equal Vacancy.new, Vacancy.new
    assert_not_equal Vacancy.new(title: "Boss"), Vacancy.new(title: "Boss")
    assert_equal Vacancy.new(title: "Boss", external_id: 100), Vacancy.new(title: "Developer", external_id: 100)
  end
  
  test "slug" do
    v1 = make(Vacancy, title: "Ruby Разработчик")
    assert_equal "#{v1.id}-ruby-разработчик", v1.slug
    
    v1.title = nil
    assert_equal v1.id.to_s, v1.slug
  end
  
  test "self.get" do
    v1 = make Vacancy

    assert_equal v1, Vacancy.get(v1.id)
    assert_equal v1, Vacancy.get(v1.id.to_s)
    assert_equal v1, Vacancy.get("#{v1.id}-xxxx-1111")
    assert_equal v1, Vacancy.get("#{v1.id}-1111-xxxx")

    assert_nil Vacancy.get("4daebd518c2e000000000000")
  end
end
