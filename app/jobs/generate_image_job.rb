# app/jobs/generate_image_job.rb
# app/jobs/generate_image_job.rb
require "stringio"
class GenerateImageJob < ApplicationJob
  queue_as :default
  def perform(prompt_id, post_id = nil)
    prompt = Prompt.find(prompt_id)
    return unless prompt.image?

    post = locate_post(prompt, post_id)
    return if post.canceled?
    return if image_already_attached?(post)
    post.update!(status: "queued") if post.draft?

    result = ComfyuiImageService.new.call(
      prompt_text: prompt.text,
      canceled: -> { post.reload.canceled? }
    ) do |prompt_id|
      mark_processing(post, prompt_id)
    end

    return if post.reload.canceled?

    attach_image(post, result.fetch(:image))
    post.update!(status: "generated")
  rescue ComfyuiImageService::Canceled => e
    mark_canceled(post, e.message)
  rescue ComfyuiImageService::Error => e
    mark_failed(post, e.message)
    Rails.logger.error("[GenerateImageJob] ComfyUI: #{e.message}")
  rescue => e
    mark_failed(post, e.message)
    Rails.logger.error("[GenerateImageJob] #{e.message}")
  end

  private

  def locate_post(prompt, post_id)
    return prompt.posts.find(post_id) if post_id.present?

    prompt.posts.order(:created_at).first || prompt.posts.create!(status: "draft", kind: prompt.kind)
  end

  def next_order_index(post)
    post.assets.maximum(:order_index).to_i + 1
  end

  def image_already_attached?(post)
    post.assets.any? { |asset| asset.file.attached? }
  end

  def attach_image(post, image)
    io = image.fetch(:io)
    io.rewind if io.respond_to?(:rewind)

    post.assets.create!(
      kind: "image",
      order_index: next_order_index(post)
    ).tap do |asset|
      asset.file.attach(
        io: io,
        filename: image[:filename].presence || "comfyui_post_#{post.id}.png",
        content_type: image[:content_type].presence || "image/png"
      )
    end
  rescue KeyError, StandardError => e
    raise ComfyuiImageService::Error, "Görsel attach başarısız: #{e.message}"
  end

  def mark_processing(post, prompt_id)
    return unless post&.persisted?

    post.update!(
      status: "processing",
      comfyui_prompt_id: prompt_id
    )
  end

  def mark_failed(post, message = nil)
    return unless post&.persisted?

    post.update(status: "failed", data: merge_data(post, "image_error" => message))
  end

  def mark_canceled(post, message = nil)
    return unless post&.persisted?

    post.update(
      status: "canceled",
      data: merge_data(post, "canceled_at" => Time.current, "image_error" => message)
    )
  end

  def merge_data(post, extra)
    safe_data = post.data.is_a?(Hash) ? post.data : {}
    safe_data.merge(extra).compact
  end
end
