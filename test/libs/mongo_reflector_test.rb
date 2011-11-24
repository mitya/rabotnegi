require 'test_helper'

unit_test MongoReflector do
  setup do
    @klass = MongoReflector.reflect('vacancies')
  end
  
  test "klass" do
    assert_equal Vacancy, @klass.reference
  end
  
  test "fields" do
    field_names = @klass.list_fields.map(&:name)
    assert_include field_names, "title"
    assert_not_include field_names, "bum_bum"
  end
  
  test "custom fields" do
    fields = @klass.list_fields
    name_field = fields.detect { |f| f.name == 'title' }
    assert_equal :link, name_field.format
  end
end
