require 'test_helper'

class VacanciesControllerTest < ActionController::TestCase
  fixtures :vacancies
  
  test 'show' do
    xhr :get, :show, :id => vacancies(:boss).to_param
    assert assigns(:vacancy)
    assert_response :ok
  end
  
  test 'index' do
    get :index, :city => :spb, :industry => :it
    assert assigns(:vacancies)
    assert assigns(:vacancies).include?(vacancies(:boss))
    assert_response :ok 
  end
end