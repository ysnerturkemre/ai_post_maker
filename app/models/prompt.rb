class Prompt < ApplicationRecord
  has_many :posts, dependent: :destroy

  enum :kind, { image: "image", video: "video" }, default: "image"

  validates :text, presence: true
  validates :kind, presence: true
  validate :video_not_supported

  private

  def video_not_supported
    return unless video?

    errors.add(:kind, I18n.t("prompts.errors.video_not_supported"))
  end
end
