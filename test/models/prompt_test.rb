require "test_helper"

class PromptTest < ActiveSupport::TestCase
  test "validates presence of text" do
    prompt = Prompt.new(text: "", kind: "image")
    assert_not prompt.valid?
    assert prompt.errors[:text].present?
  end

  test "defaults to image kind" do
    prompt = Prompt.new(text: "Hello")
    assert_equal "image", prompt.kind
  end

  test "rejects video kind" do
    prompt = Prompt.new(text: "Hello", kind: "video")
    assert_not prompt.valid?
    assert prompt.errors[:kind].present?
  end
end
