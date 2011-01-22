ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'pp'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  
  class << self
    def xtest(*args)
    end
    
    def visual_test(name, &block)
      # test(name, &block)
    end
  end  
end

def unit_test(name, &block)
  test_case = Class.new(ActiveSupport::TestCase)
  Object.const_set((name.to_s.tr_s(' :', '_') + 'Test').classify, test_case)
  test_case.class_eval(&block)
end

module CurrencyConverter
	@@rates = { :rub => 1.0, :usd => 25.0, :eur => 35.0	}
end
