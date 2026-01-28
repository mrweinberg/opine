FactoryBot.define do
  factory :item do
    sequence(:name) { |n| "Test Item #{n}" }
    category { "Places" }
    subcategory { "Restaurants" }
    association :created_by_user, factory: :user

    trait :bar do
      subcategory { "Bars" }
    end

    trait :liquor do
      category { "Things" }
      subcategory { "Liquor" }
    end
  end
end
