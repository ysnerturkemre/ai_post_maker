require "test_helper"

class GeminiCaptionServiceTest < ActiveSupport::TestCase
  test "returns variants hash" do
    result = GeminiCaptionService.new(prompt_text: "Hello").call

    assert_equal({ variants: [] }, result)
  end
end
