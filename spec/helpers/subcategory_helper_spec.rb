# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubcategoryHelper, type: :helper do
  describe "#item_sort_options" do
    it "returns expected key/label pairs" do
      options = helper.item_sort_options
      expect(options).to include([ "Newest First", "recent" ])
      expect(options).to include([ "Name A-Z", "name_asc" ])
      expect(options).to include([ "Highest Rated", "score_high" ])
      expect(options).to include([ "Most Reviewed", "most_reviewed" ])
      expect(options.length).to eq(6)
    end
  end

  describe "#review_sort_options" do
    it "returns expected key/label pairs" do
      options = helper.review_sort_options
      expect(options).to include([ "Newest First", "recent" ])
      expect(options).to include([ "Oldest First", "oldest" ])
      expect(options).to include([ "Highest Score", "score_high" ])
      expect(options).to include([ "Lowest Score", "score_low" ])
      expect(options.length).to eq(4)
    end
  end

  describe "#subcategory_path_for" do
    it "returns /restaurants for Restaurants" do
      expect(helper.subcategory_path_for("Restaurants")).to eq("/restaurants")
    end

    it "returns /tv-shows for TV Shows" do
      expect(helper.subcategory_path_for("TV Shows")).to eq("/tv-shows")
    end
  end

  describe "#filterable_attributes_for" do
    it "excludes :abv for Beer (numeric attribute)" do
      attrs = helper.filterable_attributes_for("Beer")
      expect(attrs).to include(:style, :brewery)
      expect(attrs).not_to include(:abv)
    end

    it "returns all attributes for Restaurants (none numeric)" do
      attrs = helper.filterable_attributes_for("Restaurants")
      expect(attrs).to eq([ :cuisine, :price_range, :city, :neighborhood ])
    end

    it "excludes :abv for Liquor (numeric attribute)" do
      attrs = helper.filterable_attributes_for("Liquor")
      expect(attrs).not_to include(:abv)
      expect(attrs).to include(:producer, :age_statement, :type)
    end
  end
end
