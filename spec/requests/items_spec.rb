# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Items (Homepage)", type: :request do
  describe "GET /" do
    it "renders category headings" do
      get root_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Places")
      expect(response.body).to include("Experiences")
      expect(response.body).to include("Things")
    end

    it "renders subcategory links" do
      get root_path
      expect(response.body).to include("Restaurants")
      expect(response.body).to include("Beer")
      expect(response.body).to include("TV Shows")
      expect(response.body).to include("Movies")
    end

    it "renders the recent reviews section" do
      get root_path
      expect(response.body).to include("Recent Reviews")
    end

    it "shows empty state when no reviews exist" do
      get root_path
      expect(response.body).to include("No reviews yet.")
    end

    it "shows review cards when reviews exist" do
      item = create(:item)
      review = create(:review, item: item, score: 5, body: "Absolutely wonderful!")

      get root_path
      expect(response.body).to include("Absolutely wonderful!")
      expect(response.body).to include(review.user.display_name || review.user.username)
    end

    it "limits recent reviews to 10" do
      item = create(:item)
      12.times { |i| create(:review, item: item, score: (i % 6) + 1, body: "Review number #{i}") }

      get root_path
      # Should only show 10 review cards
      expect(response.body.scan("Review number").count).to eq(10)
    end
  end
end
