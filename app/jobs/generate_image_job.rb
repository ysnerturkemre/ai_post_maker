# app/jobs/generate_image_job.rb
require "base64"
require "stringio"
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
    ).tap do |asset|
      attach_asset_file(asset, generation[:url])
    end

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

  def attach_asset_file(asset, url)
    return if url.blank? || asset.file.attached?

    if url.to_s.start_with?("data:image")
      attach_data_url(asset, url)
    elsif url.to_s.start_with?("http")
      attach_remote_url(asset, url)
    end
  rescue => e
    Rails.logger.warn("[GenerateImageJob] ActiveStorage attach failed: #{e.message}")
  end

  def attach_data_url(asset, url)
    header, encoded = url.split(",", 2)
    return if encoded.blank?

    content_type = header.to_s[/data:(.*?);base64/, 1] || "image/png"
    data = Base64.decode64(encoded)
    filename = "ai_post_#{asset.id}.png"

    asset.file.attach(
      io: StringIO.new(data),
      filename: filename,
      content_type: content_type
    )
  end

  def attach_remote_url(asset, url)
    require "open-uri"

    file = URI.open(url)
    filename = File.basename(URI.parse(url).path.presence || "ai_post_#{asset.id}.png")
    content_type = file.respond_to?(:content_type) ? file.content_type : "image/png"

    asset.file.attach(
      io: file,
      filename: filename,
      content_type: content_type
    )
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
