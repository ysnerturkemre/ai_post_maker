# app/jobs/generate_caption_job.rb
class GenerateCaptionJob < ApplicationJob
  queue_as :default
  def perform(prompt_id)
    prompt = Prompt.find_by(id: prompt_id)
    return unless prompt

    post = locate_post(prompt)
    return unless post

    result = GeminiCaptionService.new(
      prompt_text: prompt.text,
      lang: prompt.lang,
      tone: prompt.tone
    ).call

    variants = Array(result[:variants]).map(&:to_s).reject(&:blank?)
    caption = result[:selected].presence || variants.first
    return if caption.blank?

    data = merge_data(post, {
      "caption_variants" => variants.presence,
      "caption_selected_index" => caption_index(variants, caption)
    })

    post.update!(caption: caption, data: data)
  rescue GeminiCaptionService::Error => e
    mark_failed(post, e.message)
    Rails.logger.error("[GenerateCaptionJob] Gemini: #{e.message}")
  rescue => e
    mark_failed(post, e.message)
    Rails.logger.error("[GenerateCaptionJob] #{e.message}")
  end

  private

  def locate_post(prompt)
    prompt.posts.order(created_at: :desc).first || prompt.posts.create!(status: "draft", kind: prompt.kind)
  end

  def merge_data(post, extra)
    safe_data = post.data.is_a?(Hash) ? post.data : {}
    safe_data.merge(extra).compact
  end

  def caption_index(variants, caption)
    return if variants.blank? || caption.blank?

    variants.index(caption)
  end

  def mark_failed(post, message)
    return unless post&.persisted?

    post.update(data: merge_data(post, "caption_error" => message))
  end
end
