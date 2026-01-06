require "test_helper"

class AssetTest < ActiveSupport::TestCase
  test "defaults to image kind" do
    asset = Asset.new(post: posts(:one))
    assert_equal "image", asset.kind
  end

  test "belongs to post" do
    asset = assets(:one)
    assert_instance_of Post, asset.post
  end
end
