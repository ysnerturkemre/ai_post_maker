require "test_helper"

class GenerateCaptionJobTest < ActiveJob::TestCase
  test "does not raise when prompt is missing" do
    assert_silent do
      GenerateCaptionJob.perform_now(-1)
    end
  end

  test "runs with valid prompt" do
    prompt = Prompt.create!(text: "Caption prompt", kind: "image")

    assert_silent do
      GenerateCaptionJob.perform_now(prompt.id)
    end
  end
end
