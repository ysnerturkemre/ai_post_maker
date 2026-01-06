# frozen_string_literal: true

class DashboardJob
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_reader :id, :status, :prompt, :output_type, :created_at, :asset_url, :caption, :error_message

  def self.model_name
    Post.model_name
  end

  def initialize(id:, status:, prompt:, output_type:, created_at:, asset_url:, caption:, error_message:)
    @id = id
    @status = status
    @prompt = prompt
    @output_type = output_type
    @created_at = created_at
    @asset_url = asset_url
    @caption = caption
    @error_message = error_message
  end

  def to_key
    [id] if id
  end

  def persisted?
    id.present?
  end
end
