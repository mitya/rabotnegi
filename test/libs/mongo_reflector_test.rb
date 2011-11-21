require 'test_helper'

unit_test MongoReflector do
  setup do
    @metadata = MongoReflector::Metadata.new(:vacancies)
  end
  
  test "klass" do
    assert_equal Vacancy, @metadata.klass
  end
  
  test "fields" do
    field_names = @metadata.fields.map(&:name)
    assert_include field_names, "title"
    assert_not_include field_names, "bum_bum"
  end
end
