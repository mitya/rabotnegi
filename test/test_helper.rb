ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'pp'

class Test::Unit::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  fixtures :all
  
  class << self
    def test(name, &block)
      test_name = "test #{name}".to_sym
      defined = instance_method(test_name) rescue false
      raise "#{test_name} is already defined in #{self}" if defined
      define_method(test_name, &block)
    end
    
    alias visual_test test    
    alias it test
    alias its test
    
    def xtest(*args) end
    alias xvisual_test xtest    
    alias xit xtest
    alias xits xtest    
  end  
end

def describe(name, &block)
  test_case = Class.new(ActiveSupport::TestCase)
  Object.const_set((name.to_s.tr_s(' :', '_') + 'Test').classify, test_case)
  test_case.class_eval(&block)
end

def xdescribe(*args)  
end