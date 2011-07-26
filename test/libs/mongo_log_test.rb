# coding: utf-8

require 'test_helper'

unit_test MongoLog do
  setup do
    @writer = MongoLog::Writer.new('rrl-1234')
  end
  
  test "write" do
    @writer.write('info', 'start', [1,2,3], {url: "someurl", count: 100})
    
    item = MongoLog::Item.last
    assert_equal 'rrl-1234', item.puid
    assert_equal 'info', item.severity
    assert_equal 'start', item.name
    assert_equal 'rrl:start', item.full_name
    assert_equal [1,2,3], item.params
    assert_equal Hash['url' => "someurl", 'count' => 100], item.data
    assert Time.current.utc - item.created_at < 5.seconds
  end
  
  test "info" do
    @writer.info('start', 1, 2, 3, url: "someurl", count: 100)

    item = MongoLog::Item.last
    assert_equal 'info', item.severity
    assert_equal 'start', item.name
    assert_equal [1,2,3], item.params
    assert_equal Hash['url' => "someurl", 'count' => 100], item.data
  end

  test "warn" do
    @writer.warn('start')

    item = MongoLog::Item.last
    assert_equal 'warn', item.severity
    assert_equal [], item.params
    assert_equal Hash.new, item.data
  end
end
