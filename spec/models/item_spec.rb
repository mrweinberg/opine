require 'rails_helper'

RSpec.describe Item, type: :model do
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

    it "returns an empty array for subcategories without identifiers" do
      item = build(:item, category: "Experiences", subcategory: "Concerts")
      expect(item.identifier_fields).to eq([])
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

    it "returns nil for subcategories without identifiers" do
      item = build(:item, category: "Experiences", subcategory: "Concerts")
      expect(item.identifier_field).to be_nil
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

    it "returns nil for subcategories without identifiers" do
      item = build(:item, category: "Experiences", subcategory: "Concerts", metadata: {})
      expect(item.identifier_value).to be_nil
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

    it "returns just the name for subcategories without identifiers" do
      item = build(:item, name: "Lollapalooza", category: "Experiences", subcategory: "Festivals", metadata: {})
      expect(item.display_label).to eq("Lollapalooza")
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
end
