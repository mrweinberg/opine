# frozen_string_literal: true

class SubcategoriesController < ApplicationController
  ITEM_SORTS = {
    "recent"        => "items.created_at DESC",
    "name_asc"      => "items.name ASC",
    "name_desc"     => "items.name DESC",
    "score_high"    => "items.average_score DESC NULLS LAST",
    "score_low"     => "items.average_score ASC NULLS LAST",
    "most_reviewed" => "items.reviews_count DESC"
  }.freeze

  REVIEW_SORTS = {
    "recent"     => "reviews.created_at DESC",
    "oldest"     => "reviews.created_at ASC",
    "score_high" => "reviews.score DESC",
    "score_low"  => "reviews.score ASC"
  }.freeze

  # Metadata filters per subcategory (non-numeric attributes only)
  FILTERABLE_METADATA = {
    "Restaurants" => %w[cuisine price_range city neighborhood],
    "Bars"        => %w[city vibe specialty neighborhood price_range],
    "Beer"        => %w[style brewery],
    "Wine"        => %w[varietal region vintage winemaker style price_range],
    "Liquor"      => %w[producer age_statement type],
    "Movies"      => %w[director studio release_year genre],
    "TV Shows"    => %w[creator network season genre],
    "Games"       => %w[platform developer publisher genre release_year],
    "Parks"       => %w[city type features],
    "Museums"     => %w[city type specialty],
    "Concerts"    => %w[artist venue genre date city],
    "Festivals"   => %w[city type genre year price_range],
    "Books"       => %w[author genre publisher year]
  }.freeze

  def show
    @subcategory = Item::SUBCATEGORY_SLUGS[params[:subcategory_slug]]
    @category = Item::CATEGORY_MAP.find { |_k, v| v.include?(@subcategory) }&.first
    @view_mode = %w[items reviews].include?(params[:view]) ? params[:view] : "items"
    @filterable_attributes = FILTERABLE_METADATA[@subcategory] || []

    if @view_mode == "reviews"
      load_reviews
      @tag_options = build_review_tag_options
    else
      load_items
    end

    @filter_options = build_filter_options

    respond_to do |format|
      format.html
      format.turbo_stream { render partial: "content", locals: { view_mode: @view_mode } }
    end
  end

  private

  def load_items
    @items = Item.by_subcategory(@subcategory).includes(:created_by_user)

    # Text search
    @items = @items.search_by_name(params[:q]) if params[:q].present?

    # Score range filter
    @items = @items.where("average_score >= ?", params[:min_score].to_f) if params[:min_score].present?
    @items = @items.where("average_score <= ?", params[:max_score].to_f) if params[:max_score].present?

    # Metadata filters
    (@filterable_attributes || []).each do |attr|
      next unless params[attr].present?

      filter_type = Item.filter_type_for(attr)
      if filter_type == :text_search
        sanitized = params[attr].to_s.gsub(/[%_\\]/) { |c| "\\#{c}" }
        @items = @items.where("metadata ->> ? ILIKE ?", attr, "%#{sanitized}%")
      else
        @items = @items.where("metadata ->> ? = ?", attr, params[attr])
      end
    end

    # Sorting
    sort_sql = ITEM_SORTS[params[:sort]] || ITEM_SORTS["recent"]
    @items = @items.order(Arel.sql(sort_sql))
  end

  def load_reviews
    @reviews = Review.joins(:item)
                     .where(items: { subcategory: @subcategory })
                     .includes(:user, item: :created_by_user)

    # Score filter
    @reviews = @reviews.where(score: params[:score].to_i) if params[:score].present?

    # With body filter
    @reviews = @reviews.where.not(body: [ nil, "" ]) if params[:with_body] == "1"

    # My reviews filter
    @reviews = @reviews.where(user: current_user) if params[:mine] == "1" && user_signed_in?

    # Tag filter
    @reviews = @reviews.where("? = ANY(reviews.tags)", params[:tag]) if params[:tag].present?

    # Sorting
    sort_sql = REVIEW_SORTS[params[:sort]] || REVIEW_SORTS["recent"]
    @reviews = @reviews.order(Arel.sql(sort_sql))
  end

  def build_review_tag_options
    Review.distinct_tags_for_subcategory(@subcategory)
  end

  def build_filter_options
    return {} unless @view_mode == "items"

    options = {}
    (@filterable_attributes || []).each do |attr|
      filter_type = Item.filter_type_for(attr)
      case filter_type
      when :dropdown
        options[attr] = Item.distinct_metadata_values(@subcategory, attr)
      when :fixed_options
        options[attr] = Item::FIXED_FILTER_OPTIONS[attr.to_sym] || []
      end
      # :text_search needs no pre-built options
    end
    options
  end
end
