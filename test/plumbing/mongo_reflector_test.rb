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

unit_test MongoReflector::Builder do
  class TUser < ApplicationModel
    field :name
    field :email
  end
  
  setup do
  end
  
  test "list" do
    collection_1 = MongoReflector::Builder.new.desc(TUser) do
      list :id, [:name, :link], [:email, trim: 20], [:url, :link, trim: 30]
    end
    fields_1 = collection_1.list_fields.index_by { |field| field.name.to_sym }

    collection_2 = MongoReflector::Builder.new.desc(TUser) do
      list id: _, name: :link, email: {trim: 20}, url: [:link, trim: 30]
    end
    fields_2 = collection_2.list_fields.index_by { |field| field.name.to_sym }

    [fields_1, fields_2].each do |fields|
      assert_equal 'id', fields[:id].name
      assert_equal 'name', fields[:name].name
      assert_equal :link, fields[:name].format
      assert_equal 'email', fields[:email].name
      assert_equal nil, fields[:email].format
      assert_equal 20, fields[:email].trim
      assert_equal 'url', fields[:url].name
      assert_equal :link, fields[:url].format
      assert_equal 30, fields[:url].trim      
    end
  end  
  
  test "list options" do
    collection = MongoReflector::Builder.new.desc(TUser) do
      list_order :name
      list_page_size 33
      actions update: false
    end
    
    assert_equal :name, collection.list_order
    assert_equal 33, collection.list_page_size
    assert_equal false, collection.actions[:update]    
    assert_equal nil, collection.actions[:delete]    
  end
  
  test "list_css_classes" do
    collection = MongoReflector::Builder.new.desc(TUser) do
      list_css_classes { |x| {joe: x.name == 'Joe'} }
    end

    assert_equal Hash[joe: true], collection.list_css_classes.(TUser.new(name: "Joe"))
    assert_equal Hash[joe: false], collection.list_css_classes.(TUser.new(name: "Bob"))
  end
  
  test "view_subcollection" do
    
  end

  test "edit" do
    
  end
end
