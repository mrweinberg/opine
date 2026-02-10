FactoryBot.define do
  factory :item do
    sequence(:name) { |n| "Test Item #{n}" }
    category { "Places" }
    subcategory { "Restaurants" }
    metadata { { "cuisine" => "Italian", "price_range" => "$$", "neighborhood" => "Downtown", "city" => "Chicago" } }
    association :created_by_user, factory: :user

    trait :bar do
      subcategory { "Bars" }
      metadata { { "vibe" => "Chill", "specialty" => "Cocktails", "neighborhood" => "Midtown", "price_range" => "$$", "city" => "NYC" } }
    end

    trait :liquor do
      category { "Things" }
      subcategory { "Liquor" }
      metadata { { "abv" => "40%", "producer" => "Maker's Mark", "age_statement" => "NAS", "type" => "Bourbon" } }
    end

    trait :beer do
      category { "Things" }
      subcategory { "Beer" }
      metadata { { "style" => "Porter", "brewery" => "Bell's", "abv" => "5.6%" } }
    end

    trait :movie do
      category { "Experiences" }
      subcategory { "Movies" }
      metadata { { "director" => "Nolan", "studio" => "Warner Bros", "release_year" => "2024", "genre" => "Sci-Fi" } }
    end

    trait :tv_show do
      category { "Experiences" }
      subcategory { "TV Shows" }
      metadata { { "creator" => "Test Creator", "network" => "HBO", "season" => "1", "genre" => "Drama" } }
    end

    trait :game do
      category { "Experiences" }
      subcategory { "Games" }
      metadata { { "platform" => "PC", "developer" => "Valve", "publisher" => "Valve", "genre" => "FPS" } }
    end

    trait :wine do
      category { "Things" }
      subcategory { "Wine" }
      metadata { { "varietal" => "Pinot Noir", "region" => "Sonoma", "vintage" => "2020", "winemaker" => "Kosta Browne", "style" => "Red" } }
    end
  end
end
