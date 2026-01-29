class Post < ApplicationRecord
  belongs_to :user
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

  validates :user, presence: true
  validate :prompt_user_matches

  def cancelable?
    queued? || processing?
  end

  private

  def prompt_user_matches
    return if prompt.blank? || user.blank?
    return if prompt.user_id == user_id

    errors.add(:user, "must match the prompt owner")
  end
end
