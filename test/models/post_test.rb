require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "requires matching user and prompt owner" do
    prompt = prompts(:one)
    post = Post.new(prompt: prompt, user: users(:two), status: "queued", kind: "image")

    assert_not post.valid?
    assert post.errors[:user].present?
  end
end
