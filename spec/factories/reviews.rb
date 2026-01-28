FactoryBot.define do
  factory :review do
    association :user
    association :item
    score { 4 }
    body { "This is a great item!" }
  end
end
