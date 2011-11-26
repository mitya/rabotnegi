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
  
  test "keys" do
    assert_equal Vacancy, MongoReflector.reflect('vacancies').try(:reference)
    assert_equal MongoLog::Item, MongoReflector.reflect('log_items').try(:reference)
  end
  
  test "accessors" do
    vacancy = MongoReflector.reflect('vacancies')
  
    assert_equal 'vacancy', vacancy.singular
    assert_equal 'vacancies', vacancy.plural
    assert_equal 'vacancies', vacancy.key
    assert_equal true, vacancy.searchable?
    assert_equal Vacancy, vacancy.reference

    log_item = MongoReflector.reflect('log_items')
  
    assert_equal 'mongo_log_item', log_item.singular
    assert_equal 'mongo_log_items', log_item.plural
    assert_equal 'log_items', log_item.key
    assert_equal true, log_item.searchable?
    assert_equal MongoLog::Item, log_item.reference
  end
  
  test "edit_fields" do
    fields = @klass.edit_fields
  end
end
