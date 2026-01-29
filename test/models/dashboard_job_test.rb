require "test_helper"

class DashboardJobTest < ActiveSupport::TestCase
  test "stores caption and error fields" do
    job = DashboardJob.new(
      id: 1,
      status: "failed",
      prompt: "prompt",
      output_type: "image",
      created_at: Time.current,
      asset_url: nil,
      caption: nil,
      error_message: "image failed",
      caption_error: "caption failed"
    )

    assert_equal "caption failed", job.caption_error
    assert_equal "image failed", job.error_message
  end
end
