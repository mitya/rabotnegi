require 'test_helper'

class ControllerHelperTest < ActionView::TestCase
  test "decode_order_for_mongo" do
    assert_equal [["date", Mongo::ASCENDING]], decode_order_for_mongo("date")
    assert_equal [["date", Mongo::DESCENDING]], decode_order_for_mongo("-date")
  end
end
