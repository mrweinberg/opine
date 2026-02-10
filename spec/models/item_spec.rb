require 'rails_helper'

RSpec.describe Item, type: :model do
  describe "IDENTIFIER_FIELD" do
    it "maps each subcategory to its identifier attribute" do
      expect(Item::IDENTIFIER_FIELD["Beer"]).to eq(:brewery)
      expect(Item::IDENTIFIER_FIELD["Wine"]).to eq(:winemaker)
      expect(Item::IDENTIFIER_FIELD["Liquor"]).to eq(:producer)
      expect(Item::IDENTIFIER_FIELD["Movies"]).to eq(:director)
      expect(Item::IDENTIFIER_FIELD["TV Shows"]).to eq(:season)
      expect(Item::IDENTIFIER_FIELD["Games"]).to eq(:developer)
      expect(Item::IDENTIFIER_FIELD["Restaurants"]).to eq(:city)
      expect(Item::IDENTIFIER_FIELD["Bars"]).to eq(:city)
    end
  end

  describe "#identifier_field" do
    it "returns the identifier attribute for the subcategory" do
      item = build(:item, subcategory: "Beer")
      expect(item.identifier_field).to eq(:brewery)
    end

    it "returns nil for subcategories without identifiers" do
      item = build(:item, category: "Experiences", subcategory: "Concerts")
      expect(item.identifier_field).to be_nil
    end
  end

  describe "#identifier_value" do
    it "returns the value from metadata for the identifier field" do
      item = build(:item, subcategory: "Beer", metadata: { "brewery" => "Bell's" })
      expect(item.identifier_value).to eq("Bell's")
    end

    it "returns nil when identifier field is not set in metadata" do
      item = build(:item, subcategory: "Beer", metadata: {})
      expect(item.identifier_value).to be_nil
    end

    it "returns nil for subcategories without identifiers" do
      item = build(:item, category: "Experiences", subcategory: "Concerts", metadata: {})
      expect(item.identifier_value).to be_nil
    end
  end

  describe "#display_label" do
    it "returns 'Name — Identifier' when identifier is present" do
      item = build(:item, name: "Porter", subcategory: "Beer", metadata: { "brewery" => "Bell's" })
      expect(item.display_label).to eq("Porter — Bell's")
    end

    it "returns just the name when identifier is not set" do
      item = build(:item, name: "Porter", subcategory: "Beer", metadata: {})
      expect(item.display_label).to eq("Porter")
    end

    it "returns just the name for subcategories without identifiers" do
      item = build(:item, name: "Lollapalooza", category: "Experiences", subcategory: "Festivals", metadata: {})
      expect(item.display_label).to eq("Lollapalooza")
    end

    it "works for places with city identifier" do
      item = build(:item, name: "Canlis", subcategory: "Restaurants", metadata: { "city" => "Seattle" })
      expect(item.display_label).to eq("Canlis — Seattle")
    end

    it "works for movies with director identifier" do
      item = build(:item, name: "Oppenheimer", category: "Experiences", subcategory: "Movies", metadata: { "director" => "Christopher Nolan" })
      expect(item.display_label).to eq("Oppenheimer — Christopher Nolan")
    end
  end
end
