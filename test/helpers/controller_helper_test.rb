require 'test_helper'

class ControllerHelperTest < ActionView::TestCase
  include ApplicationHelper
  
  test "decode_order_for_mongo" do
    assert_equal [["date", Mongo::ASCENDING]], decode_order_for_mongo("date")
    assert_equal [["date", Mongo::DESCENDING]], decode_order_for_mongo("-date")
  end
  
  test "web_id" do
    vacancy = make Vacancy
    assert_equal "v-#{vacancy.id}", web_id(vacancy)
    assert_equal "v-#{vacancy.id}-details", web_id(vacancy, :details)
  end
end
