# frozen_string_literal: true

class Item < ApplicationRecord
  CATEGORY_MAP = {
    "Places"      => [ "Restaurants", "Bars", "Parks", "Museums" ],
    "Experiences" => [ "Concerts", "Festivals", "Movies", "Games", "TV Shows", "Books" ],
    "Things"      => [ "Beer", "Wine", "Liquor" ]
  }.freeze

  SUBCATEGORY_SLUGS = {
    "restaurants" => "Restaurants", "bars" => "Bars", "parks" => "Parks",
    "museums" => "Museums", "concerts" => "Concerts", "festivals" => "Festivals",
    "movies" => "Movies", "games" => "Games", "tv-shows" => "TV Shows",
    "books" => "Books", "beer" => "Beer", "wine" => "Wine", "liquor" => "Liquor"
  }.freeze

  IDENTIFIER_FIELD = {
    "Restaurants" => :city,
    "Bars"        => :city,
    "Parks"       => :city,
    "Museums"     => :city,
    "Concerts"    => :artist,
    "Festivals"   => :city,
    "Beer"        => :brewery,
    "Wine"        => [ :winemaker, :vintage ],
    "Liquor"      => :producer,
    "Movies"      => :director,
    "TV Shows"    => :season,
    "Games"       => :developer,
    "Books"       => :author
  }.freeze

  ATTRIBUTE_DEFINITIONS = {
    "Restaurants" => [ :cuisine, :price_range, :city, :neighborhood ],
    "Bars"        => [ :city, :vibe, :specialty, :neighborhood, :price_range ],
    "Parks"       => [ :city, :type, :features ],
    "Museums"     => [ :city, :type, :specialty ],
    "Concerts"    => [ :artist, :venue, :genre, :date, :city ],
    "Festivals"   => [ :city, :type, :genre, :year, :price_range ],
    "Liquor"      => [ :abv, :producer, :age_statement, :type ],
    "Wine"        => [ :varietal, :region, :vintage, :winemaker, :style, :alcohol, :price_range ],
    "Beer"        => [ :style, :brewery, :abv ],
    "Movies"      => [ :director, :studio, :release_year, :genre ],
    "TV Shows"    => [ :creator, :network, :season, :genre ],
    "Games"       => [ :platform, :developer, :publisher, :genre, :release_year ],
    "Books"       => [ :author, :genre, :publisher, :year ]
  }.freeze

  ATTRIBUTE_FILTER_TYPES = {
    # Text search — rendered as text input, ILIKE partial match
    city: :text_search, neighborhood: :text_search, cuisine: :text_search,
    artist: :text_search, venue: :text_search, director: :text_search,
    studio: :text_search, creator: :text_search, network: :text_search,
    developer: :text_search, publisher: :text_search, producer: :text_search,
    winemaker: :text_search, brewery: :text_search, region: :text_search,
    specialty: :text_search, features: :text_search, age_statement: :text_search,
    varietal: :text_search, date: :text_search, author: :text_search,
    # Dropdown — rendered as select from distinct DB values, exact match
    type: :dropdown, style: :dropdown, genre: :dropdown, vibe: :dropdown,
    platform: :dropdown, vintage: :dropdown, release_year: :dropdown, season: :dropdown,
    year: :dropdown,
    # Fixed options — rendered as select from predefined values, exact match
    price_range: :fixed_options,
    # Numeric — excluded from filters
    abv: :numeric, alcohol: :numeric
  }.freeze

  FIXED_FILTER_OPTIONS = {
    price_range: [ "$", "$$", "$$$", "$$$$" ]
  }.freeze

  def self.filter_type_for(attribute)
    ATTRIBUTE_FILTER_TYPES[attribute.to_sym] || :dropdown
  end

  include PgSearch::Model
  pg_search_scope :search_by_name,
                  against: [ :name, :city, :producer, :vintage, :release_year, :season ],
                  using: {
                    tsearch: { prefix: true, dictionary: "english" }
                  }

  belongs_to :created_by_user, class_name: "User", optional: true, inverse_of: :items
  has_many :reviews, dependent: :destroy

  accepts_nested_attributes_for :reviews

  after_create_commit :enrich_with_ai

  validates :name, presence: true, length: { maximum: 255 }
  validates :category, presence: true, inclusion: { in: CATEGORY_MAP.keys }
  validates :subcategory, presence: true
  validate :subcategory_matches_category
  validate :required_attributes_present

  scope :by_subcategory, ->(subcategory) { where(subcategory: subcategory) }

  def self.slug_for(subcategory_name)
    SUBCATEGORY_SLUGS.key(subcategory_name)
  end

  def self.distinct_metadata_values(subcategory, attribute)
    attr_s = attribute.to_s
    by_subcategory(subcategory)
      .where("metadata ->> ? IS NOT NULL AND metadata ->> ? != ''", attr_s, attr_s)
      .distinct.pluck(Arel.sql("metadata ->> '#{connection.quote_string(attr_s)}'"))
      .compact.sort
  end

  def expected_attributes
    ATTRIBUTE_DEFINITIONS[subcategory] || []
  end

  # Always returns an array of identifier symbols (may be empty)
  def identifier_fields
    Array(IDENTIFIER_FIELD[subcategory])
  end

  # For backward compat — returns first identifier field or nil
  def identifier_field
    identifier_fields.first
  end

  # Returns a single joined string of all identifier values, or nil
  def identifier_value
    vals = identifier_fields.filter_map { |f| metadata&.dig(f.to_s).presence }
    vals.any? ? vals.join(" ") : nil
  end

  # "Pinot Noir — Kosta Browne 2020" or just "Porter — Bell's" or just "Porter"
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

  def enrich_with_ai
    AiItemEnrichmentJob.perform_later(id)
  end
end
