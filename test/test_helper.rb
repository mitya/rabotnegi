ENV["RAILS_ENV"] = "test"
# ENV["RAILS_ENV"] = "testreal"

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'pp'
require "mocks"

FactoryGirl.find_definitions

module Testing
  module GlobalHelpers
    def unit_test(name, &block)
      test_case = Class.new(ActiveSupport::TestCase)
      Object.const_set((name.to_s.tr_s(' :', '_') + 'Test').classify, test_case)
      test_case.class_eval(&block)
    end    

    def web_test(name, &block)
      test_case = Class.new(WebTest)
      Object.const_set((name.to_s.tr_s(' :', '_') + 'WebTest').classify, test_case)
      test_case.class_eval(&block)
    end
  end
  
  module TestHelpers
    def make(factory_name, *args, &block)
      factory_name = factory_name.model_name.singular if Class === factory_name
      Factory(factory_name, *args, &block)
    end
  end
  
  module CaseHelpers
    def no_test(*args)
    end
    
    def visual_test(name, &block)
      # test(name, &block)
    end    
  end
  
  module Assertions
    def assert_size(size, collection)
      assert_equal size, collection.size
    end    
    
    def assert_same_elements(a1, a2)
      assert_equal a1.size, a2.size
      a1.each { |x| assert a2.include?(x), "#{a2.inspect} is expected to include #{x.inspect}" }
    end
  end
end

include Testing::GlobalHelpers

class ActiveSupport::TestCase
  fixtures :all

  self.use_transactional_fixtures = true  
  self.use_instantiated_fixtures  = false

  include Testing::TestHelpers
  include Testing::Assertions
  extend Testing::CaseHelpers
  
  teardown do
    Vacancy.delete_all
    User.delete_all
  end unless Rails.env.testreal?
end

raise "No vacancies in the database" if Rails.env.testreal? && Vacancy.count < 100

require 'capybara/rails'
Capybara.javascript_driver = :webkit

class WebTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  def method_missing(method, *args, &block)
    return super unless method.to_s.starts_with?("assert_")
    predicate = method.to_s.sub(/^assert_/, '') + '?'
    return super unless page.respond_to?(predicate)
    assert page.send(predicate, *args, &block), "Failure: page.#{predicate}#{args.inspect}"
  end
end
