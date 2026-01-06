class Post < ApplicationRecord
  belongs_to :prompt
  has_many :assets, dependent: :destroy

  enum :status, {
    draft: "draft",
    generated: "generated",
    processing: "processing",
    queued: "queued",
    published: "published",
    failed: "failed",
    canceled: "canceled"
  }, default: "draft"

  enum :kind, {
    image: "image", video: "video" }, default: "image"

  def cancelable?
    queued? || processing?
  end
end
