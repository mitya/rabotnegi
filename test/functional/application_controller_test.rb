require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  tests SiteController

  test "default locale" do
    get :locale
    assert_equal :ru, I18n.locale
  end
  
  test "error notifications" do
    $test_error_reporting_enabled = true
    Err.delete_all
    
    assert_raise ArgumentError do
      get :error
    end
    
    assert_equal 1, Err.count
    assert_emails 1

    puts response.code
  end
  
  teardown do
    $test_error_reporting_enabled = false
  end
end
