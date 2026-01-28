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
