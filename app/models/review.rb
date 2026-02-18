# frozen_string_literal: true

class Review < ApplicationRecord
  belongs_to :user
  belongs_to :item, counter_cache: true

  has_many_attached :images

  validates :score, presence: true, inclusion: { in: 1..6, message: "must be between 1 and 6" }
  validates :body, length: { maximum: 5000 }
  validates :user_id, uniqueness: { scope: :item_id, message: "has already reviewed this item" }
  validate :images_count_within_limit
  validate :tags_within_limits

  before_validation :normalize_tags

  after_save :update_item_score
  after_destroy :update_item_score

  scope :recent, -> { order(created_at: :desc) }

  def self.distinct_tags_for_subcategory(subcategory)
    joins(:item).where(items: { subcategory: subcategory })
      .where.not(tags: [])
      .pluck(:tags).flatten.uniq.sort
  end

  private

  def normalize_tags
    self.tags = (tags || []).map { |t| t.to_s.strip.downcase }.reject(&:blank?).uniq.first(5)
  end

  def tags_within_limits
    return if tags.blank?

    errors.add(:tags, "can have at most 5 tags") if tags.length > 5
    errors.add(:tags, "each tag must be 20 characters or fewer") if tags.any? { |t| t.length > 20 }
  end

  def images_count_within_limit
    return unless images.attached? && images.count > 5

    errors.add(:images, "can have at most 5 images")
  end

  def update_item_score
    item.recalculate_score!
  end
end
