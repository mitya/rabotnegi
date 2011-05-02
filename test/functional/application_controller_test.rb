require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  tests SiteController

  test "default locale" do
    get :locale
    assert_equal :ru, I18n.locale
  end
end
