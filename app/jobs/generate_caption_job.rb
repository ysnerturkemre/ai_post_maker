# app/jobs/generate_caption_job.rb
class GenerateCaptionJob < ApplicationJob
  queue_as :default
  def perform(prompt_id)
    prompt = Prompt.find(prompt_id)
    # YARIN: GeminiCaptionService ile 3 varyant üret, Post.create!
  rescue => e
    Rails.logger.error("[GenerateCaptionJob] #{e.message}")
  end
end
