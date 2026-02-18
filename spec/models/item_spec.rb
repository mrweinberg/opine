require 'rails_helper'

RSpec.describe Item, type: :model do
  describe "SUBCATEGORY_SLUGS" do
    it "covers all subcategories in CATEGORY_MAP" do
      all_subcategories = Item::CATEGORY_MAP.values.flatten.sort
      slug_subcategories = Item::SUBCATEGORY_SLUGS.values.sort
      expect(slug_subcategories).to eq(all_subcategories)
    end

    it "maps each slug to the correct subcategory name" do
      expect(Item::SUBCATEGORY_SLUGS["restaurants"]).to eq("Restaurants")
      expect(Item::SUBCATEGORY_SLUGS["beer"]).to eq("Beer")
      expect(Item::SUBCATEGORY_SLUGS["tv-shows"]).to eq("TV Shows")
      expect(Item::SUBCATEGORY_SLUGS["concerts"]).to eq("Concerts")
      expect(Item::SUBCATEGORY_SLUGS["festivals"]).to eq("Festivals")
      expect(Item::SUBCATEGORY_SLUGS["parks"]).to eq("Parks")
      expect(Item::SUBCATEGORY_SLUGS["museums"]).to eq("Museums")
      expect(Item::SUBCATEGORY_SLUGS["books"]).to eq("Books")
    end
  end

  describe "ATTRIBUTE_DEFINITIONS" do
    it "defines Parks attributes" do
      expect(Item::ATTRIBUTE_DEFINITIONS["Parks"]).to eq([ :city, :type, :features ])
    end

    it "defines Museums attributes" do
      expect(Item::ATTRIBUTE_DEFINITIONS["Museums"]).to eq([ :city, :type, :specialty ])
    end

    it "defines Concerts attributes" do
      expect(Item::ATTRIBUTE_DEFINITIONS["Concerts"]).to eq([ :artist, :venue, :genre, :date, :city ])
    end

    it "defines Festivals attributes" do
      expect(Item::ATTRIBUTE_DEFINITIONS["Festivals"]).to eq([ :city, :type, :genre, :year, :price_range ])
    end

    it "defines Books attributes" do
      expect(Item::ATTRIBUTE_DEFINITIONS["Books"]).to eq([ :author, :genre, :publisher, :year ])
    end
  end

  describe "IDENTIFIER_FIELD" do
    it "maps each subcategory to its identifier attribute(s)" do
      expect(Item::IDENTIFIER_FIELD["Beer"]).to eq(:brewery)
      expect(Item::IDENTIFIER_FIELD["Wine"]).to eq([ :winemaker, :vintage ])
      expect(Item::IDENTIFIER_FIELD["Liquor"]).to eq(:producer)
      expect(Item::IDENTIFIER_FIELD["Movies"]).to eq(:director)
      expect(Item::IDENTIFIER_FIELD["TV Shows"]).to eq(:season)
      expect(Item::IDENTIFIER_FIELD["Games"]).to eq(:developer)
      expect(Item::IDENTIFIER_FIELD["Restaurants"]).to eq(:city)
      expect(Item::IDENTIFIER_FIELD["Bars"]).to eq(:city)
    end

    it "maps Concerts identifier to :artist" do
      expect(Item::IDENTIFIER_FIELD["Concerts"]).to eq(:artist)
    end

    it "maps Festivals identifier to :city" do
      expect(Item::IDENTIFIER_FIELD["Festivals"]).to eq(:city)
    end

    it "maps Books identifier to :author" do
      expect(Item::IDENTIFIER_FIELD["Books"]).to eq(:author)
    end
  end

  describe "#identifier_fields" do
    it "returns an array for single identifiers" do
      item = build(:item, :beer)
      expect(item.identifier_fields).to eq([ :brewery ])
    end

    it "returns an array for compound identifiers" do
      item = build(:item, :wine)
      expect(item.identifier_fields).to eq([ :winemaker, :vintage ])
    end

    it "returns an array for concerts with artist identifier" do
      item = build(:item, :concert)
      expect(item.identifier_fields).to eq([ :artist ])
    end
  end

  describe "#identifier_field" do
    it "returns the first identifier attribute for the subcategory" do
      item = build(:item, :beer)
      expect(item.identifier_field).to eq(:brewery)
    end

    it "returns the first of compound identifiers" do
      item = build(:item, :wine)
      expect(item.identifier_field).to eq(:winemaker)
    end

    it "returns :artist for concerts" do
      item = build(:item, :concert)
      expect(item.identifier_field).to eq(:artist)
    end
  end

  describe "#identifier_value" do
    it "returns the value from metadata for a single identifier" do
      item = build(:item, :beer, metadata: { "style" => "Porter", "brewery" => "Bell's", "abv" => "5.6%" })
      expect(item.identifier_value).to eq("Bell's")
    end

    it "joins compound identifier values" do
      item = build(:item, :wine, metadata: { "varietal" => "Pinot Noir", "region" => "Sonoma", "vintage" => "2020", "winemaker" => "Kosta Browne", "style" => "Red" })
      expect(item.identifier_value).to eq("Kosta Browne 2020")
    end

    it "returns partial compound identifier when one field is missing" do
      item = build(:item, :wine, metadata: { "varietal" => "Pinot Noir", "region" => "Sonoma", "vintage" => "", "winemaker" => "Kosta Browne", "style" => "Red" })
      expect(item.identifier_value).to eq("Kosta Browne")
    end

    it "returns nil when identifier field is not set in metadata" do
      item = build(:item, :beer, metadata: { "style" => "Porter", "abv" => "5.6%" })
      expect(item.identifier_value).to be_nil
    end

    it "returns the artist for concerts" do
      item = build(:item, :concert)
      expect(item.identifier_value).to eq("Radiohead")
    end
  end

  describe "#display_label" do
    it "returns 'Name — Identifier' for single identifier" do
      item = build(:item, :beer, name: "Porter", metadata: { "style" => "Porter", "brewery" => "Bell's", "abv" => "5.6%" })
      expect(item.display_label).to eq("Porter — Bell's")
    end

    it "returns 'Name — Compound' for compound identifiers" do
      item = build(:item, :wine, name: "Pinot Noir", metadata: { "varietal" => "Pinot Noir", "region" => "Sonoma", "vintage" => "2020", "winemaker" => "Kosta Browne", "style" => "Red" })
      expect(item.display_label).to eq("Pinot Noir — Kosta Browne 2020")
    end

    it "returns just the name when identifier is not set" do
      item = build(:item, :beer, name: "Porter", metadata: { "style" => "Porter", "abv" => "5.6%" })
      expect(item.display_label).to eq("Porter")
    end

    it "returns 'Name — City' for festivals with city identifier" do
      item = build(:item, :festival, name: "Lollapalooza")
      expect(item.display_label).to eq("Lollapalooza — Austin")
    end

    it "works for places with city identifier" do
      item = build(:item, name: "Canlis", subcategory: "Restaurants", metadata: { "cuisine" => "Fine Dining", "price_range" => "$$$$", "neighborhood" => "Queen Anne", "city" => "Seattle" })
      expect(item.display_label).to eq("Canlis — Seattle")
    end

    it "works for movies with director identifier" do
      item = build(:item, name: "Oppenheimer", category: "Experiences", subcategory: "Movies", metadata: { "director" => "Christopher Nolan", "studio" => "Universal", "release_year" => "2023", "genre" => "Drama" })
      expect(item.display_label).to eq("Oppenheimer — Christopher Nolan")
    end
  end

  describe "ATTRIBUTE_FILTER_TYPES" do
    it "classifies all attributes from ATTRIBUTE_DEFINITIONS" do
      all_attrs = Item::ATTRIBUTE_DEFINITIONS.values.flatten.uniq
      all_attrs.each do |attr|
        expect(Item::ATTRIBUTE_FILTER_TYPES).to have_key(attr),
          "Missing filter type for #{attr}"
      end
    end

    it "maps city to :text_search" do
      expect(Item::ATTRIBUTE_FILTER_TYPES[:city]).to eq(:text_search)
    end

    it "maps genre to :dropdown" do
      expect(Item::ATTRIBUTE_FILTER_TYPES[:genre]).to eq(:dropdown)
    end

    it "maps price_range to :fixed_options" do
      expect(Item::ATTRIBUTE_FILTER_TYPES[:price_range]).to eq(:fixed_options)
    end

    it "maps abv to :numeric" do
      expect(Item::ATTRIBUTE_FILTER_TYPES[:abv]).to eq(:numeric)
    end
  end

  describe "FIXED_FILTER_OPTIONS" do
    it "defines price_range options" do
      expect(Item::FIXED_FILTER_OPTIONS[:price_range]).to eq([ "$", "$$", "$$$", "$$$$" ])
    end
  end

  describe ".filter_type_for" do
    it "returns the filter type for a known attribute" do
      expect(Item.filter_type_for(:cuisine)).to eq(:text_search)
      expect(Item.filter_type_for(:style)).to eq(:dropdown)
      expect(Item.filter_type_for(:price_range)).to eq(:fixed_options)
      expect(Item.filter_type_for(:abv)).to eq(:numeric)
    end

    it "accepts string arguments" do
      expect(Item.filter_type_for("cuisine")).to eq(:text_search)
    end

    it "defaults to :dropdown for unknown attributes" do
      expect(Item.filter_type_for(:unknown_attr)).to eq(:dropdown)
    end
  end

  describe ".distinct_metadata_values" do
    it "returns sorted unique values for a given subcategory and attribute" do
      create(:item, name: "Place A", metadata: { "cuisine" => "Italian", "price_range" => "$$", "city" => "Chicago", "neighborhood" => "Downtown" })
      create(:item, name: "Place B", metadata: { "cuisine" => "Mexican", "price_range" => "$$", "city" => "Chicago", "neighborhood" => "Uptown" })
      create(:item, name: "Place C", metadata: { "cuisine" => "Italian", "price_range" => "$$$", "city" => "NYC", "neighborhood" => "Soho" })

      values = Item.distinct_metadata_values("Restaurants", :cuisine)
      expect(values).to eq([ "Italian", "Mexican" ])
    end

    it "excludes nil and blank values" do
      create(:item, name: "Place A", metadata: { "cuisine" => "Italian", "price_range" => "$$", "city" => "Chicago", "neighborhood" => "Downtown" })
      # Use insert to bypass validation for blank cuisine
      item = build(:item, name: "Place B", metadata: { "cuisine" => "Temp", "price_range" => "$$", "city" => "NYC", "neighborhood" => "Soho" })
      item.save!
      item.update_columns(metadata: { "cuisine" => "", "price_range" => "$$", "city" => "NYC", "neighborhood" => "Soho" })

      values = Item.distinct_metadata_values("Restaurants", :cuisine)
      expect(values).to eq([ "Italian" ])
    end

    it "returns empty array when no items exist" do
      values = Item.distinct_metadata_values("Restaurants", :cuisine)
      expect(values).to eq([])
    end
  end
end
