require 'rails_helper'

RSpec.describe Review, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:item) }
  end

  describe "validations" do
    subject { build(:review) }

    it { is_expected.to validate_presence_of(:score) }
    it { is_expected.to validate_inclusion_of(:score).in_range(1..6).with_message("must be between 1 and 6") }
    it { is_expected.to validate_length_of(:body).is_at_most(5000) }

    context "uniqueness" do
      let!(:existing_review) { create(:review) }

      it "prevents duplicate reviews from same user on same item" do
        duplicate = build(:review, user: existing_review.user, item: existing_review.item)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:user_id]).to include("has already reviewed this item")
      end

      it "allows same user to review different items" do
        other_item = create(:item)
        review = build(:review, user: existing_review.user, item: other_item)
        expect(review).to be_valid
      end

      it "allows different users to review same item" do
        other_user = create(:user)
        review = build(:review, user: other_user, item: existing_review.item)
        expect(review).to be_valid
      end
    end
  end

  describe "score validation" do
    it "rejects scores below 1" do
      review = build(:review, score: 0)
      expect(review).not_to be_valid
    end

    it "rejects scores above 6" do
      review = build(:review, score: 7)
      expect(review).not_to be_valid
    end

    it "accepts scores 1-6" do
      (1..6).each do |score|
        review = build(:review, score: score)
        expect(review).to be_valid
      end
    end
  end

  describe "tag normalization" do
    it "strips whitespace, downcases, and deduplicates tags" do
      review = build(:review, tags: [ " Cozy ", "COZY", " hoppy ", "Fresh" ])
      review.valid?
      expect(review.tags).to eq(%w[cozy hoppy fresh])
    end

    it "removes blank tags" do
      review = build(:review, tags: [ "cozy", "", "  ", "hoppy" ])
      review.valid?
      expect(review.tags).to eq(%w[cozy hoppy])
    end

    it "truncates to 5 tags" do
      review = build(:review, tags: %w[a b c d e f g])
      review.valid?
      expect(review.tags.length).to eq(5)
    end
  end

  describe "tag validation" do
    it "accepts up to 5 valid tags" do
      review = build(:review, tags: %w[cozy trendy hoppy fresh bright])
      expect(review).to be_valid
    end

    it "accepts empty tags" do
      review = build(:review, tags: [])
      expect(review).to be_valid
    end

    it "rejects tags longer than 20 characters" do
      review = build(:review, tags: [ "a" * 21 ])
      expect(review).not_to be_valid
      expect(review.errors[:tags]).to include("each tag must be 20 characters or fewer")
    end
  end

  describe ".distinct_tags_for_subcategory" do
    it "returns unique sorted tags for a subcategory" do
      restaurant = create(:item, name: "Place A",
                          metadata: { "cuisine" => "Italian", "price_range" => "$$", "city" => "Chicago", "neighborhood" => "Downtown" })
      restaurant2 = create(:item, name: "Place B",
                           metadata: { "cuisine" => "Mexican", "price_range" => "$", "city" => "Austin", "neighborhood" => "East Side" })
      beer_item = create(:item, :beer, name: "Some IPA")

      create(:review, item: restaurant, tags: %w[cozy date-night])
      create(:review, item: restaurant2, tags: %w[cozy spicy])
      create(:review, item: beer_item, tags: %w[hoppy])

      result = Review.distinct_tags_for_subcategory("Restaurants")
      expect(result).to eq(%w[cozy date-night spicy])
    end

    it "excludes reviews with empty tags" do
      restaurant = create(:item, name: "Place C",
                          metadata: { "cuisine" => "Italian", "price_range" => "$$", "city" => "NYC", "neighborhood" => "SoHo" })
      create(:review, item: restaurant, tags: [])

      result = Review.distinct_tags_for_subcategory("Restaurants")
      expect(result).to eq([])
    end
  end

  describe "score aggregation" do
    let(:item) { create(:item) }

    it "updates item average_score after create" do
      user1 = create(:user)
      user2 = create(:user)

      create(:review, item: item, user: user1, score: 4)
      expect(item.reload.average_score.to_f).to eq(4.0)
      expect(item.reviews_count).to eq(1)

      create(:review, item: item, user: user2, score: 6)
      expect(item.reload.average_score.to_f).to eq(5.0)
      expect(item.reviews_count).to eq(2)
    end

    it "updates item average_score after destroy" do
      user1 = create(:user)
      user2 = create(:user)

      review1 = create(:review, item: item, user: user1, score: 4)
      create(:review, item: item, user: user2, score: 6)

      review1.destroy
      expect(item.reload.average_score.to_f).to eq(6.0)
      expect(item.reviews_count).to eq(1)
    end

    it "clears average_score when last review deleted" do
      review = create(:review, item: item, score: 5)
      review.destroy
      expect(item.reload.average_score).to be_nil
      expect(item.reviews_count).to eq(0)
    end
  end
end
