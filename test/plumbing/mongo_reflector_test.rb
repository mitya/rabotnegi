require 'test_helper'

unit_test MongoReflector do
  setup do
    @collection = MongoReflector.metadata_for('vacancies')
  end
  
  test "klass" do
    assert_equal Vacancy, @collection.klass
  end
  
  test "fields" do
    field_names = @collection.list_fields.map(&:name)
    assert_include field_names, "title"
    assert_not_include field_names, "bum_bum"
  end
  
  test "custom fields" do
    fields = @collection.list_fields
    name_field = fields.detect { |f| f.name == 'title' }
    assert_equal :link, name_field.format
  end
  
  test "keys" do
    assert_equal Vacancy, MongoReflector.metadata_for('vacancies').try(:klass)
    assert_equal MongoLog::Item, MongoReflector.metadata_for('log_items').try(:klass)
  end
  
  test "accessors" do
    vacancy = MongoReflector.metadata_for('vacancies')
  
    assert_equal 'vacancy', vacancy.singular
    assert_equal 'vacancies', vacancy.plural
    assert_equal 'vacancies', vacancy.key
    assert_equal true, vacancy.searchable?
    assert_equal Vacancy, vacancy.klass

    log_item = MongoReflector.metadata_for('log_items')
  
    assert_equal 'mongo_log_item', log_item.singular
    assert_equal 'mongo_log_items', log_item.plural
    assert_equal 'log_items', log_item.key
    assert_equal true, log_item.searchable?
    assert_equal MongoLog::Item, log_item.klass
  end
  
  test "edit_fields" do
    fields = @collection.edit_fields
  end
end
