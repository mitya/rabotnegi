ENV["RAILS_ENV"] = ENV["X_RAILS_ENV"] || "test"

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'pp'
require "support/mocks"
require "support/factories"
require "support/helpers"
require "support/capybara"

raise "No vacancies in the database" if Rails.env.test_real? && Vacancy.count < 100

class ActiveSupport::TestCase
  fixtures :all

  self.use_transactional_fixtures = true  
  self.use_instantiated_fixtures  = false

  include ActionMailer::TestHelper
  include Testing::TestHelpers
  include Testing::Assertions
  extend Testing::CaseHelpers
  
  teardown do
    Vacancy.delete_all
    User.delete_all
  end unless Rails.env.test_real? || Rails.env.test_web?
end
