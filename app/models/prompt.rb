class Prompt < ApplicationRecord
  has_many :posts, dependent: :destroy

  enum :kind, { image: "image", video: "video" }, default: "image"

  validates :text, presence: true
  validates :kind, presence: true
end
