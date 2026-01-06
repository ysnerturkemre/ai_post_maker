require "test_helper"

class GenerateCaptionJobTest < ActiveJob::TestCase
  test "does not raise when prompt is missing" do
    assert_silent do
      GenerateCaptionJob.perform_now(-1)
    end
  end

  test "runs with valid prompt" do
    prompt = Prompt.create!(text: "Caption prompt", kind: "image")
    post = prompt.posts.create!(status: "queued", kind: "image")
    service = Object.new
    service.define_singleton_method(:call) do
      { variants: ["Caption A", "Caption B"], selected: "Caption A" }
    end

    GeminiCaptionService.stub(:new, ->(*, **){ service }) do
      assert_silent do
        GenerateCaptionJob.perform_now(prompt.id)
      end
    end

    post.reload
    assert_equal "Caption A", post.caption
    assert_equal ["Caption A", "Caption B"], post.data["caption_variants"]
    assert_equal 0, post.data["caption_selected_index"]
  end
end
