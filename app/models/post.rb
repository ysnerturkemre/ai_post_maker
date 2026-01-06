class Post < ApplicationRecord
  belongs_to :prompt
  has_many :assets, dependent: :destroy

  enum :status, {
    draft: "draft",
    generated: "generated",
    queued: "queued",
    published: "published",
    failed: "failed"
  }, default: "draft"

  enum :kind, {
    image: "image", video: "video" }, default: "image"
end
