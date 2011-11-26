require 'test_helper'

unit_test MongoLog do
  setup do
    @writer = MongoLog::Writer.new('RRL_1234')
  end
  
  test "write" do
    @writer.write 'info', 'start', 1, 2, 3, env: {url: "someurl", count: 100}
    
    item = MongoLog::Item.last
    assert_equal 'RRL_1234', item.puid
    assert_equal 'info', item.severity
    assert_equal 'start', item.title
    assert_equal [1,2,3], item.brief
    assert_equal Hash['url' => "someurl", 'count' => 100], item.data
    assert Time.current.utc - item.created_at < 5.seconds
  end
  
  test "info" do
    @writer.info('start', 1, 2, 3, env: {url: "someurl", count: 100}, xxx: 123)

    item = MongoLog::Item.last
    assert_equal 'info', item.severity
    assert_equal 'start', item.title
    assert_equal [1,2,3, {'xxx' => 123}], item.brief
    assert_equal Hash['url' => "someurl", 'count' => 100], item.data
  end

  test "warn" do
    @writer.warn('start')

    item = MongoLog::Item.last
    assert_equal 'warn', item.severity
    assert_equal [], item.brief
    assert_equal Hash.new, item.data
  end
end
