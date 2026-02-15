# app/controllers/share_pages_controller.rb
class SharePagesController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  include ActionView::Helpers::TextHelper

  def show
    post = Post.includes(:assets, :prompt).find(params[:id])
    asset_url = asset_url_for(post.assets.first)
    share_url = "#{request.base_url}#{share_landing_path(post.id)}"
    title = truncate(post.prompt&.text.to_s.presence || "AI Post", length: 120)
    description = truncate(post.caption.to_s.presence || post.prompt&.text.to_s, length: 220)

    @page_title = title
    @share_meta = {
      title: title,
      description: description,
      image_url: asset_url.to_s,
      share_url: share_url
    }

    render Shares::LandingPageComponent.new(post: post, asset_url: asset_url, share_url: share_url)
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  private

  def asset_url_for(asset)
    return nil if asset.blank?

    if asset.file.attached?
      url_for(asset.file)
    else
      asset.file_url
    end
  rescue => e
    Rails.logger.warn("[SharePagesController] asset url error: #{e.message}")
    asset.file_url
  end
end
