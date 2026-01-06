class Asset < ApplicationRecord
  belongs_to :post
  has_one_attached :file
  enum :kind, {
    image: "image", video: "video"
  }, default: "image"
end
