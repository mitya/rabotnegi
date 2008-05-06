module RSpecExtensions
  def is(value = true)
    self.should == value
  end

  def isnt(value)
    self.should_not == value
  end

  alias method_missing_without_rspec method_missing
  def method_missing(method, *args, &block)
    return method_missing_without_rspec(method, *args, &block) if method.to_s !~ /^should_/
    method = method.to_s
    
    if method == 'should_raise'
      'should raise some exception'.should == nil
    end
    
    expected_result = method =~ /^should_not_/ ? false : true
    
    original_method = method.sub(/should(_not)?(_be)?_/, '')
    original_method += '?' if respond_to?(original_method + '?')
  
    result = send(original_method, *args, &block)
    result.should == expected_result
  end
end

Spec::Example::ExampleGroupMethods.module_eval do
  alias its it
  alias visual_test it
  
  def nit(message = nil) end
  alias disabled_visual_test nit  
end
Object.class_eval { include RSpecExtensions }