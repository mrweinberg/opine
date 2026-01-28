# frozen_string_literal: true

class Item < ApplicationRecord
  CATEGORY_MAP = {
    "Places"      => [ "Restaurants", "Bars", "Parks", "Museums" ],
    "Experiences" => [ "Concerts", "Festivals", "Movies", "Games" ],
    "Things"      => [ "Beer", "Wine", "Liquor" ]
  }.freeze

  ATTRIBUTE_DEFINITIONS = {
    "Restaurants" => [ :cuisine, :price_range, :neighborhood ],
    "Bars"        => [ :vibe, :specialty, :neighborhood, :price_range ],
    "Liquor"      => [ :abv, :producer, :age_statement, :type ],
    "Wine"        => [ :varietal, :region, :vintage, :winemaker, :style ],
    "Beer"        => [ :style, :brewery, :abv ],
    "Movies"      => [ :director, :studio, :release_year, :genre ],
    "Games"       => [ :platform, :developer, :publisher, :genre ]
  }.freeze

  belongs_to :created_by_user, class_name: "User", optional: true, inverse_of: :items
  has_many :reviews, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validates :category, presence: true, inclusion: { in: CATEGORY_MAP.keys }
  validates :subcategory, presence: true
  validate :subcategory_matches_category

  scope :by_category, ->(category) { where(category: category) }
  scope :by_subcategory, ->(subcategory) { where(subcategory: subcategory) }

  def expected_attributes
    ATTRIBUTE_DEFINITIONS[subcategory] || []
  end

  def recalculate_score!
    avg = reviews.average(:score)
    update_columns(average_score: avg, reviews_count: reviews.count)
  end

  private

  def subcategory_matches_category
    return if category.blank? || subcategory.blank?

    valid_subcategories = CATEGORY_MAP[category] || []
    return if valid_subcategories.include?(subcategory)

    errors.add(:subcategory, "is not valid for category '#{category}'")
  end
end
