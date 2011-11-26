require 'test_helper'

unit_test RussianInflector do
  test "parameterize" do
    assert_equal "ruby-developer", RussianInflector.parameterize("Ruby Developer")    
    assert_equal "ruby-разработчик", RussianInflector.parameterize("Ruby Разработчик")    
    assert_equal "ruby-разработчик", RussianInflector.parameterize("Ruby - Разработчик.")  
    assert_equal "торговый-представитель-20", RussianInflector.parameterize("Торговый представитель № 20")
  end
end
