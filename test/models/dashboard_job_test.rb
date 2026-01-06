require "test_helper"

class DashboardJobTest < ActiveSupport::TestCase
  test "exposes model_name as Post" do
    assert_equal Post.model_name, DashboardJob.model_name
  end

  test "reports persisted when id present" do
    job = DashboardJob.new(
      id: 10,
      status: "queued",
      prompt: "Hello",
      output_type: "image",
      created_at: Time.current,
      asset_url: nil,
      error_message: nil
    )

    assert job.persisted?
    assert_equal [10], job.to_key
  end

  test "reports not persisted without id" do
    job = DashboardJob.new(
      id: nil,
      status: "queued",
      prompt: "Hello",
      output_type: "image",
      created_at: nil,
      asset_url: nil,
      error_message: nil
    )

    assert_not job.persisted?
    assert_nil job.to_key
  end
end
