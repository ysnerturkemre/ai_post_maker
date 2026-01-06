# app/services/gemini_caption_service.rb
class GeminiCaptionService
  class Error < StandardError; end

  DEFAULT_LANG = "tr"
  DEFAULT_TONE = "friendly"

  def initialize(prompt_text:, lang: DEFAULT_LANG, tone: DEFAULT_TONE)
    @prompt_text = prompt_text.to_s.strip
    @lang = lang.presence || DEFAULT_LANG
    @tone = tone.presence || DEFAULT_TONE
  end

  def call
    raise Error, "Prompt metni boş olamaz." if @prompt_text.blank?

    variants = build_variants
    { variants: variants, selected: variants.first }
  end

  private

  def build_variants
    base = truncate_text(@prompt_text, 160)
    hashtags = hashtags_for(@lang)
    cta = cta_for(@tone, @lang)

    [
      "#{base}\n\n#{hashtags}",
      "#{base}\n\n#{cta}\n#{hashtags}",
      "#{cta}\n\n#{base}\n\n#{hashtags}"
    ].map(&:strip)
  end

  def hashtags_for(lang)
    case lang.to_s
    when "en"
      "#ai #content #creator #socialmedia #instagram"
    else
      "#yapayzeka #icerik #uretken #instagram #sosyalmedya"
    end
  end

  def cta_for(tone, lang)
    return "Save this for later." if lang.to_s == "en"
    return "Kaydetmeyi unutma." if tone.to_s == "friendly"

    "Kaydetmek istersen."
  end

  def truncate_text(text, length)
    return text if text.length <= length

    text[0, length].rstrip + "..."
  end
end
