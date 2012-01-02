require 'test_helper'

unit_test Mai do
  test "alias" do
    assert_equal Mu, Mai
    assert_equal gg, Mai
  end
  
  test "interpolate" do
    assert_equal "/some/url?region=spb&industry=it", M.interpolate("/some/url?region={city}&industry={industry}", city: :spb, industry: "it")
  end
end
