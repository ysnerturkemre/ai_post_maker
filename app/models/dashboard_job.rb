# frozen_string_literal: true

class DashboardJob
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_reader :id, :status, :prompt, :output_type, :created_at, :asset_url, :caption, :error_message, :caption_error

  def self.model_name
    Post.model_name
  end

  def initialize(id:, status:, prompt:, output_type:, created_at:, asset_url:, caption:, error_message:, caption_error:)
    @id = id
    @status = status
    @prompt = prompt
    @output_type = output_type
    @created_at = created_at
    @asset_url = asset_url
    @caption = caption
    @error_message = error_message
    @caption_error = caption_error
  end

  def to_key
    [id] if id
  end

  def persisted?
    id.present?
  end
end
