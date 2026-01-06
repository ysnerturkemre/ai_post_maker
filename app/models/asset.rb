class Asset < ApplicationRecord
  belongs_to :post
  enum :kind, {
    image: "image", video: "video"
  }, default: "image"
end
