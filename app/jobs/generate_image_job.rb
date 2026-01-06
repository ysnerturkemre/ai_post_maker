# app/jobs/generate_image_job.rb
class GenerateImageJob < ApplicationJob
  queue_as :default
  def perform(prompt_id, post_id = nil)
    prompt = Prompt.find(prompt_id)
    return unless prompt.image?

    post = locate_post(prompt, post_id)
    return if post.canceled?
    post.update!(status: "queued") if post.draft?

    generation = AiHordeImageService.new(prompt_text: prompt.text, aspect: :square).call(
      canceled: -> { post.reload.canceled? }
    ) do |job_id|
      mark_processing(post, job_id)
    end

    return if post.reload.canceled?
    raise AiHordeImageService::Error, "Görsel URL alınamadı." if generation[:url].blank?

    post.assets.create!(
      kind: "image",
      file_url: generation[:url],
      width: generation[:width],
      height: generation[:height],
      order_index: next_order_index(post)
    )

    post.update!(status: "generated")
  rescue AiHordeImageService::Canceled => e
    mark_canceled(post, e.message)
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

  def mark_processing(post, job_id)
    return unless post&.persisted?

    post.update!(
      status: "processing",
      data: merge_data(post, "ai_horde_job_id" => job_id)
    )
  end

  def mark_failed(post, message = nil)
    return unless post&.persisted?

    post.update(status: "failed", data: merge_data(post, "error" => message))
  end

  def mark_canceled(post, message = nil)
    return unless post&.persisted?

    post.update(
      status: "canceled",
      data: merge_data(post, "error" => message, "canceled_at" => Time.current)
    )
  end

  def merge_data(post, extra)
    safe_data = post.data.is_a?(Hash) ? post.data : {}
    safe_data.merge(extra).compact
  end
end
