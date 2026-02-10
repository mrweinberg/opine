# frozen_string_literal: true

class Item < ApplicationRecord
  CATEGORY_MAP = {
    "Places"      => [ "Restaurants", "Bars", "Parks", "Museums" ],
    "Experiences" => [ "Concerts", "Festivals", "Movies", "Games", "TV Shows" ],
    "Things"      => [ "Beer", "Wine", "Liquor" ]
  }.freeze

  IDENTIFIER_FIELD = {
    "Restaurants" => :city,
    "Bars"        => :city,
    "Parks"       => :city,
    "Museums"     => :city,
    "Beer"        => :brewery,
    "Wine"        => :winemaker,
    "Liquor"      => :producer,
    "Movies"      => :director,
    "TV Shows"    => :season,
    "Games"       => :developer
  }.freeze

  ATTRIBUTE_DEFINITIONS = {
    "Restaurants" => [ :cuisine, :price_range, :neighborhood ],
    "Bars"        => [ :vibe, :specialty, :neighborhood, :price_range ],
    "Liquor"      => [ :abv, :producer, :age_statement, :type ],
    "Wine"        => [ :varietal, :region, :vintage, :winemaker, :style ],
    "Beer"        => [ :style, :brewery, :abv ],
    "Movies"      => [ :director, :studio, :release_year, :genre ],
    "TV Shows"    => [ :creator, :network, :season, :genre ],
    "Games"       => [ :platform, :developer, :publisher, :genre ]
  }.freeze

  include PgSearch::Model
  pg_search_scope :search_by_name,
                  against: [ :name, :city, :producer, :vintage, :release_year, :season ],
                  using: {
                    tsearch: { prefix: true, dictionary: "english" }
                  }

  belongs_to :created_by_user, class_name: "User", optional: true, inverse_of: :items
  has_many :reviews, dependent: :destroy

  accepts_nested_attributes_for :reviews

  validates :name, presence: true, length: { maximum: 255 }
  validates :category, presence: true, inclusion: { in: CATEGORY_MAP.keys }
  validates :subcategory, presence: true
  validate :subcategory_matches_category
  validate :required_attributes_present

  scope :by_category, ->(category) { where(category: category) }
  scope :by_subcategory, ->(subcategory) { where(subcategory: subcategory) }

  def expected_attributes
    ATTRIBUTE_DEFINITIONS[subcategory] || []
  end

  def identifier_field
    IDENTIFIER_FIELD[subcategory]
  end

  def identifier_value
    field = identifier_field
    field ? metadata&.dig(field.to_s) : nil
  end

  # "Porter — Bell's" or just "Porter" if no identifier
  def display_label
    id_val = identifier_value
    id_val.present? ? "#{name} — #{id_val}" : name
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

  def required_attributes_present
    return if subcategory.blank?

    missing = expected_attributes.select { |attr| metadata&.dig(attr.to_s).blank? }
    return if missing.empty?

    missing.each do |attr|
      errors.add(:base, "#{attr.to_s.humanize.titleize} is required for #{subcategory}")
    end
  end
end
