require "test_helper"
require "stringio"

class GenerateImageJobTest < ActiveJob::TestCase
  test "creates asset and updates post status" do
    user = users(:one)
    prompt = Prompt.create!(text: "Image prompt", kind: "image", user: user)
    post = prompt.posts.create!(status: "draft", kind: "image", user: user)

    service = Object.new
    service.define_singleton_method(:call) do |prompt_text:, client_id: "ai_post_maker", canceled: nil, &block|
      block&.call("prompt_123")
      {
        prompt_id: "prompt_123",
        image: {
          io: StringIO.new("fake"),
          content_type: "image/png",
          filename: "output.png"
        }
      }
    end

    ComfyuiImageService.stub(:new, ->(*, **){ service }) do
      assert_difference -> { Asset.count }, 1 do
        GenerateImageJob.perform_now(prompt.id, post.id)
      end
    end

    post.reload
    assert_equal "generated", post.status
    assert_equal 1, post.assets.count
    assert_equal "prompt_123", post.comfyui_prompt_id
    assert post.assets.first.file.attached?
  end

  test "skips non-image prompts" do
    prompt = Prompt.create!(text: "Video prompt", kind: "image", user: users(:one))
    prompt.update_column(:kind, "video")

    assert_no_difference -> { Post.count } do
      GenerateImageJob.perform_now(prompt.id)
    end
  end

  test "marks post failed on service error" do
    user = users(:one)
    prompt = Prompt.create!(text: "Failing prompt", kind: "image", user: user)
    post = prompt.posts.create!(status: "draft", kind: "image", user: user)
    service = Object.new
    def service.call(prompt_text:, client_id: "ai_post_maker", canceled: nil, &block)
      raise ComfyuiImageService::Error, "boom"
    end

    ComfyuiImageService.stub(:new, ->(*, **){ service }) do
      GenerateImageJob.perform_now(prompt.id, post.id)
    end

    post.reload
    assert_equal "failed", post.status
    assert_equal "boom", post.data["image_error"]
  end

  test "marks post canceled when generation is canceled" do
    user = users(:one)
    prompt = Prompt.create!(text: "Canceled prompt", kind: "image", user: user)
    post = prompt.posts.create!(status: "draft", kind: "image", user: user)
    service = Object.new
    service.define_singleton_method(:call) do |prompt_text:, client_id: "ai_post_maker", canceled: nil, &block|
      block&.call("prompt_456")
      post.update!(status: "canceled")
      raise ComfyuiImageService::Canceled, "stop" if canceled&.call
      { prompt_id: "prompt_456", image: { io: StringIO.new("fake"), content_type: "image/png", filename: "out.png" } }
    end

    ComfyuiImageService.stub(:new, ->(*, **){ service }) do
      assert_no_difference -> { Asset.count } do
        GenerateImageJob.perform_now(prompt.id, post.id)
      end
    end

    post.reload
    assert_equal "canceled", post.status
    assert_equal "stop", post.data["image_error"]
    assert_equal "prompt_456", post.comfyui_prompt_id
  end
end
