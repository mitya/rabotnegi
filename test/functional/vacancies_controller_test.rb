# coding: utf-8

require 'test_helper'

class VacanciesControllerTest < ActionController::TestCase
  test 'show' do
    @vacancy = make Vacancy, city: "spb", industry: "it", title: "Программист"
        
    xhr :get, :show, id: @vacancy.to_param
    
    assert_response :ok
    assert_equal @vacancy, assigns(:vacancy)
    assert_template "vacancy"
  end
  
  test 'index' do
    make Vacancy, city: "spb", industry: "it"
    make Vacancy, city: "spb", industry: "it"
    make Vacancy, city: "msk", industry: "it"
    make Vacancy, city: "spb", industry: "opt"
    
    get :index, city: 'spb', industry: 'it'
    
    assert_response :ok
    assert_size 2, assigns(:vacancies)
    assert_template "index"
  end
  
  test "index - sorting" do
    v1 = make Vacancy, city: "spb", industry: "it", employer_name: "AAA"
    v2 = make Vacancy, city: "spb", industry: "it", employer_name: "BBB"
  
    get :index, city: 'spb', industry: 'it', sort: "employer_name"
    assert_equal [v1, v2], assigns(:vacancies)
  
    get :index, city: 'spb', industry: 'it', sort: "-employer_name"
    assert_equal [v2, v1], assigns(:vacancies)
  end
end
