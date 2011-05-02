require 'test_helper'

class VacanciesControllerTest < ActionController::TestCase
  setup do
    @vacancy = make Vacancy, city: "spb", industry: "it"
  end
  
  test 'show' do
    xhr :get, :show, :id => @vacancy.to_param
    assert assigns(:vacancy)
    assert_response :ok
  end
  
  test 'index' do
    get :index, :city => 'spb', :industry => 'it'
    assert assigns(:vacancies)
    assert assigns(:vacancies).include?(@vacancy)
    assert_response :ok 
  end
end
