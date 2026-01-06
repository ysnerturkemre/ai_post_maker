# app/services/gemini_caption_service.rb
class GeminiCaptionService
  def initialize(prompt_text:, lang: "tr", tone: "friendly"); @prompt_text, @lang, @tone = prompt_text, lang, tone; end
  def call
    # YARIN: Gemini API çağrısı — 3 caption + hashtag
    { variants: [] }
  end
end
