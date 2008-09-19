require 'test_helper'

class TestController < ApplicationController
  def test
    render :text => 'ok'
  end
end

class ApplicationControllerTest < ActionController::TestCase
  tests TestController

  test "default locale" do
    get :test
    assert_equal 'ru-RU', I18n.locale
  end
end
