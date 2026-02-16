# frozen_string_literal: true

module SubcategoryHelper
  ITEM_SORT_OPTIONS = [
    [ "Newest First", "recent" ],
    [ "Name A-Z", "name_asc" ],
    [ "Name Z-A", "name_desc" ],
    [ "Highest Rated", "score_high" ],
    [ "Lowest Rated", "score_low" ],
    [ "Most Reviewed", "most_reviewed" ]
  ].freeze

  REVIEW_SORT_OPTIONS = [
    [ "Newest First", "recent" ],
    [ "Oldest First", "oldest" ],
    [ "Highest Score", "score_high" ],
    [ "Lowest Score", "score_low" ]
  ].freeze

  def item_sort_options
    ITEM_SORT_OPTIONS
  end

  def review_sort_options
    REVIEW_SORT_OPTIONS
  end

  def subcategory_path_for(subcategory_name)
    slug = Item.slug_for(subcategory_name)
    slug ? subcategory_path(subcategory_slug: slug) : "#"
  end

  def filterable_attributes_for(subcategory)
    attrs = Item::ATTRIBUTE_DEFINITIONS[subcategory] || []
    attrs.reject { |a| Item.filter_type_for(a) == :numeric }
  end
end
