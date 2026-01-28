require 'rails_helper'

RSpec.describe ReviewPolicy, type: :policy do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:other_user) { create(:user) }
  let(:item) { create(:item) }
  let(:review) { create(:review, user: user, item: item) }

  describe "#create?" do
    context "when user is signed in" do
      it "allows if user hasn't reviewed this item" do
        new_review = item.reviews.build
        policy = described_class.new(other_user, new_review)
        expect(policy.create?).to be true
      end

      it "denies if user already reviewed this item" do
        review # create the review
        new_review = item.reviews.build
        policy = described_class.new(user, new_review)
        expect(policy.create?).to be false
      end
    end

    context "when user is not signed in" do
      it "denies" do
        new_review = item.reviews.build
        policy = described_class.new(nil, new_review)
        expect(policy.create?).to be false
      end
    end
  end

  describe "#update?" do
    it "allows author to update" do
      policy = described_class.new(user, review)
      expect(policy.update?).to be true
    end

    it "denies other users" do
      policy = described_class.new(other_user, review)
      expect(policy.update?).to be false
    end

    it "denies admin (only author can edit)" do
      policy = described_class.new(admin, review)
      expect(policy.update?).to be false
    end
  end

  describe "#destroy?" do
    it "allows author to delete" do
      policy = described_class.new(user, review)
      expect(policy.destroy?).to be true
    end

    it "allows admin to delete" do
      policy = described_class.new(admin, review)
      expect(policy.destroy?).to be true
    end

    it "denies other users" do
      policy = described_class.new(other_user, review)
      expect(policy.destroy?).to be false
    end
  end
end
