FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:username) { |n| "user#{n}" }
    password { "password123" }
    display_name { "Test User" }
    role { :user }

    trait :admin do
      role { :admin }
    end

    trait :superadmin do
      role { :superadmin }
    end
  end
end
