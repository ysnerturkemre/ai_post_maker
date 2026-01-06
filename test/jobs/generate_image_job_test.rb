require "test_helper"

class GenerateImageJobTest < ActiveJob::TestCase
  test "creates asset and updates post status" do
    prompt = Prompt.create!(text: "Image prompt", kind: "image")
    post = prompt.posts.create!(status: "draft", kind: "image")
    service = Object.new
    service.define_singleton_method(:call) do |canceled: nil, &block|
      block&.call("job_123")
      { url: "https://example.com/img.png", width: 100, height: 100 }
    end

    AiHordeImageService.stub(:new, ->(*, **){ service }) do
      assert_difference -> { Asset.count }, 1 do
        GenerateImageJob.perform_now(prompt.id, post.id)
      end
    end

    post.reload
    assert_equal "generated", post.status
    assert_equal 1, post.assets.count
    assert_equal "job_123", post.data["ai_horde_job_id"]
  end

  test "skips non-image prompts" do
    prompt = Prompt.create!(text: "Video prompt", kind: "image")
    prompt.update_column(:kind, "video")

    assert_no_difference -> { Post.count } do
      GenerateImageJob.perform_now(prompt.id)
    end
  end

  test "marks post failed on service error" do
    prompt = Prompt.create!(text: "Failing prompt", kind: "image")
    post = prompt.posts.create!(status: "draft", kind: "image")
    service = Object.new
    def service.call(canceled: nil, &block)
      raise AiHordeImageService::Error, "boom"
    end

    AiHordeImageService.stub(:new, ->(*, **){ service }) do
      assert_raises(AiHordeImageService::Error) do
        GenerateImageJob.perform_now(prompt.id, post.id)
      end
    end

    post.reload
    assert_equal "failed", post.status
    assert_equal "boom", post.data["error"]
  end

  test "marks post canceled when generation is canceled" do
    prompt = Prompt.create!(text: "Canceled prompt", kind: "image")
    post = prompt.posts.create!(status: "draft", kind: "image")
    service = Object.new
    service.define_singleton_method(:call) do |canceled: nil, &block|
      block&.call("job_456")
      post.update!(status: "canceled")
      raise AiHordeImageService::Canceled, "stop" if canceled&.call
      { url: "https://example.com/img.png", width: 100, height: 100 }
    end

    AiHordeImageService.stub(:new, ->(*, **){ service }) do
      assert_no_difference -> { Asset.count } do
        GenerateImageJob.perform_now(prompt.id, post.id)
      end
    end

    post.reload
    assert_equal "canceled", post.status
    assert_equal "stop", post.data["error"]
    assert_equal "job_456", post.data["ai_horde_job_id"]
  end
end
