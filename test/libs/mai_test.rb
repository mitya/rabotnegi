# coding: utf-8

require 'test_helper'

unit_test Mai do
  test "alias" do
    assert_equal mai, Mai
  end
  
  test "interpolate" do
    assert_equal "/some/url?region=spb&industry=it", mai.interpolate("/some/url?region={city}&industry={industry}", city: :spb, industry: "it")
  end
end
