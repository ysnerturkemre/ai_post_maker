# app/jobs/generate_image_job.rb
class GenerateImageJob < ApplicationJob
  queue_as :default
  def perform(prompt_id, post_id = nil)
    prompt = Prompt.find(prompt_id)
    return unless prompt.image?

    post = nil
    post = locate_post(prompt, post_id)
    post.update!(status: "queued") if post.draft?

    generation = AiHordeImageService.new(prompt_text: prompt.text, aspect: :square).call
    raise AiHordeImageService::Error, "Görsel URL alınamadı." if generation[:url].blank?

    post.assets.create!(
      kind: "image",
      file_url: generation[:url],
      width: generation[:width],
      height: generation[:height],
      order_index: next_order_index(post)
    )

    post.update!(status: "generated")
  rescue AiHordeImageService::Error => e
    mark_failed(post, e.message)
    Rails.logger.error("[GenerateImageJob] AI Horde: #{e.message}")
    raise
  rescue => e
    mark_failed(post, e.message)
    Rails.logger.error("[GenerateImageJob] #{e.message}")
    raise
  end

  private

  def locate_post(prompt, post_id)
    return prompt.posts.find(post_id) if post_id.present?

    prompt.posts.order(:created_at).first || prompt.posts.create!(status: "draft", kind: prompt.kind)
  end

  def next_order_index(post)
    post.assets.maximum(:order_index).to_i + 1
  end

  def mark_failed(post, message = nil)
    return unless post&.persisted?

    safe_data = post.data.is_a?(Hash) ? post.data : {}
    merged_data = safe_data.merge("error" => message).compact
    post.update(status: "failed", data: merged_data)
  end
end
