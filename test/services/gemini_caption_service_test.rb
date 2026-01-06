require "test_helper"

class GeminiCaptionServiceTest < ActiveSupport::TestCase
  test "returns variants hash" do
    result = GeminiCaptionService.new(prompt_text: "Hello").call

    assert result[:variants].is_a?(Array)
    assert result[:variants].any?
    assert_equal result[:variants].first, result[:selected]
  end

  test "raises when prompt is blank" do
    assert_raises(GeminiCaptionService::Error) do
      GeminiCaptionService.new(prompt_text: "  ").call
    end
  end
end
