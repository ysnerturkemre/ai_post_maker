require "test_helper"

class GenerateImageJobTest < ActiveJob::TestCase
  test "creates asset and updates post status" do
    prompt = Prompt.create!(text: "Image prompt", kind: "image")
    post = prompt.posts.create!(status: "draft", kind: "image")
    service = Struct.new(:call).new({ url: "https://example.com/img.png", width: 100, height: 100 })

    AiHordeImageService.stub(:new, ->(*, **){ service }) do
      assert_difference -> { Asset.count }, 1 do
        GenerateImageJob.perform_now(prompt.id, post.id)
      end
    end

    post.reload
    assert_equal "generated", post.status
    assert_equal 1, post.assets.count
  end

  test "skips non-image prompts" do
    prompt = Prompt.create!(text: "Video prompt", kind: "video")

    assert_no_difference -> { Post.count } do
      GenerateImageJob.perform_now(prompt.id)
    end
  end

  test "marks post failed on service error" do
    prompt = Prompt.create!(text: "Failing prompt", kind: "image")
    post = prompt.posts.create!(status: "draft", kind: "image")
    service = Object.new
    def service.call
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
end
