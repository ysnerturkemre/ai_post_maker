require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "defaults to draft status" do
    post = Post.new(prompt: prompts(:one), kind: "image")
    assert_equal "draft", post.status
  end

  test "belongs to prompt" do
    post = posts(:one)
    assert_instance_of Prompt, post.prompt
  end

  test "supports enum statuses" do
    post = posts(:one)
    post.status = "generated"
    assert post.valid?
  end
end
