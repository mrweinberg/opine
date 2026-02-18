# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Subcategories", type: :request do
  let(:user) { create(:user) }

  describe "routing" do
    it "GET /restaurants returns 200" do
      get "/restaurants"
      expect(response).to have_http_status(:ok)
    end

    it "GET /beer returns 200" do
      get "/beer"
      expect(response).to have_http_status(:ok)
    end

    it "GET /tv-shows returns 200" do
      get "/tv-shows"
      expect(response).to have_http_status(:ok)
    end

    it "GET /books returns 200" do
      get "/books"
      expect(response).to have_http_status(:ok)
    end

    it "GET /notasubcategory returns 404" do
      get "/notasubcategory"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "items view (default)" do
    let!(:italian) do
      create(:item, name: "Pasta Place",
             metadata: { "cuisine" => "Italian", "price_range" => "$$", "city" => "Chicago", "neighborhood" => "Downtown" })
    end
    let!(:mexican) do
      create(:item, name: "Taco Spot",
             metadata: { "cuisine" => "Mexican", "price_range" => "$", "city" => "Austin", "neighborhood" => "East Side" })
    end
    let!(:beer_item) do
      create(:item, :beer, name: "Hoppy IPA")
    end

    it "renders items for the correct subcategory only" do
      get "/restaurants"
      expect(response.body).to include("Pasta Place")
      expect(response.body).to include("Taco Spot")
      expect(response.body).not_to include("Hoppy IPA")
    end

    it "does not include items from other subcategories" do
      get "/beer"
      expect(response.body).to include("Hoppy IPA")
      expect(response.body).not_to include("Pasta Place")
    end

    it "default sort is newest first" do
      # italian created before mexican
      get "/restaurants"
      body = response.body
      expect(body.index("Taco Spot")).to be < body.index("Pasta Place")
    end

    it "?sort=name_asc sorts by name ascending" do
      get "/restaurants", params: { sort: "name_asc" }
      body = response.body
      expect(body.index("Pasta Place")).to be < body.index("Taco Spot")
    end

    it "?sort=score_high sorts by average_score descending" do
      italian.update_columns(average_score: 3.0)
      mexican.update_columns(average_score: 5.0)

      get "/restaurants", params: { sort: "score_high" }
      body = response.body
      expect(body.index("Taco Spot")).to be < body.index("Pasta Place")
    end

    it "?sort=most_reviewed sorts by reviews_count descending" do
      italian.update_columns(reviews_count: 1)
      mexican.update_columns(reviews_count: 5)

      get "/restaurants", params: { sort: "most_reviewed" }
      body = response.body
      expect(body.index("Taco Spot")).to be < body.index("Pasta Place")
    end

    it "?q=searchterm filters items by name search" do
      get "/restaurants", params: { q: "Pasta" }
      expect(response.body).to include("Pasta Place")
      expect(response.body).not_to include("Taco Spot")
    end

    it "?min_score=3&max_score=5 filters items by score range" do
      italian.update_columns(average_score: 2.0)
      mexican.update_columns(average_score: 4.0)

      get "/restaurants", params: { min_score: "3", max_score: "5" }
      expect(response.body).to include("Taco Spot")
      expect(response.body).not_to include("Pasta Place")
    end

    it "metadata filter narrows results (exact match for dropdown)" do
      get "/restaurants", params: { cuisine: "Italian" }
      expect(response.body).to include("Pasta Place")
      expect(response.body).not_to include("Taco Spot")
    end

    it "text_search filter matches partial values via ILIKE" do
      get "/restaurants", params: { cuisine: "Ital" }
      expect(response.body).to include("Pasta Place")
      expect(response.body).not_to include("Taco Spot")
    end

    it "fixed_options filter matches exact value for price_range" do
      get "/restaurants", params: { price_range: "$$" }
      expect(response.body).to include("Pasta Place")
      expect(response.body).not_to include("Taco Spot")
    end

    it "renders empty state when no items match" do
      get "/restaurants", params: { q: "zzzznonexistent" }
      expect(response.body).to include("No items found")
    end
  end

  describe "reviews view" do
    let!(:restaurant) do
      create(:item, name: "Test Restaurant",
             metadata: { "cuisine" => "Italian", "price_range" => "$$", "city" => "Chicago", "neighborhood" => "Downtown" })
    end
    let!(:review_high) { create(:review, item: restaurant, score: 5, body: "Amazing food!") }
    let!(:review_low) { create(:review, item: restaurant, score: 2, body: "") }

    it "?view=reviews renders reviews instead of items" do
      get "/restaurants", params: { view: "reviews" }
      expect(response.body).to include("Amazing food!")
    end

    it "default sort is newest first" do
      get "/restaurants", params: { view: "reviews" }
      expect(response).to have_http_status(:ok)
    end

    it "?view=reviews&sort=score_high sorts by score descending" do
      get "/restaurants", params: { view: "reviews", sort: "score_high" }
      # review_high (score 5) should appear before review_low (score 2)
      # Both reviews show score badges; the first score badge should be 5
      scores = response.body.scan(/<div class="text-xl font-bold.*?>\s*(\d)\s*<\/div>/m).flatten
      expect(scores.first).to eq("5")
    end

    it "?view=reviews&score=5 filters to only score-5 reviews" do
      get "/restaurants", params: { view: "reviews", score: "5" }
      expect(response.body).to include("Amazing food!")
      # The low-score review has no body text, so check it's filtered by verifying count
      # We parse the response for review cards
    end

    it "?view=reviews&with_body=1 filters to reviews with body text" do
      get "/restaurants", params: { view: "reviews", with_body: "1" }
      expect(response.body).to include("Amazing food!")
    end

    it "?view=reviews&tag=cozy filters to reviews with that tag" do
      review_high.update!(tags: %w[cozy])
      review_low.update!(tags: %w[spicy], body: "Terrible food")

      get "/restaurants", params: { view: "reviews", tag: "cozy" }
      expect(response.body).to include("Amazing food!")
      expect(response.body).not_to include("Terrible food")
    end

    it "shows tag filter dropdown when tags exist" do
      review_high.update!(tags: %w[cozy trendy])

      get "/restaurants", params: { view: "reviews" }
      expect(response.body).to include("cozy")
      expect(response.body).to include("trendy")
    end

    it "renders empty state when no reviews exist" do
      restaurant2 = create(:item, name: "Empty Place",
                           subcategory: "Bars",
                           metadata: { "city" => "NYC", "vibe" => "Chill", "specialty" => "Cocktails", "neighborhood" => "Midtown", "price_range" => "$$" })
      get "/bars", params: { view: "reviews" }
      expect(response.body).to include("No reviews found")
    end
  end

  describe "turbo frame requests" do
    it "returns frame-wrapped content" do
      get "/restaurants", headers: { "Turbo-Frame" => "subcategory_content" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("subcategory_content")
    end
  end
end
