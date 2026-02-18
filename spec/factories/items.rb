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
      metadata { { "platform" => "PC", "developer" => "Valve", "publisher" => "Valve", "genre" => "FPS", "release_year" => "2024" } }
    end

    trait :wine do
      category { "Things" }
      subcategory { "Wine" }
      metadata { { "varietal" => "Pinot Noir", "region" => "Sonoma", "vintage" => "2020", "winemaker" => "Kosta Browne", "style" => "Red", "alcohol" => "13.5%", "price_range" => "$$$" } }
    end

    trait :park do
      category { "Places" }
      subcategory { "Parks" }
      metadata { { "city" => "Denver", "type" => "National", "features" => "Trails" } }
    end

    trait :museum do
      category { "Places" }
      subcategory { "Museums" }
      metadata { { "city" => "Chicago", "type" => "Art", "specialty" => "Modern Art" } }
    end

    trait :concert do
      category { "Experiences" }
      subcategory { "Concerts" }
      metadata { { "artist" => "Radiohead", "venue" => "Madison Square Garden", "genre" => "Rock", "date" => "2024-07-15", "city" => "New York" } }
    end

    trait :festival do
      category { "Experiences" }
      subcategory { "Festivals" }
      metadata { { "city" => "Austin", "type" => "Music", "genre" => "Indie", "year" => "2024", "price_range" => "$$" } }
    end

    trait :book do
      category { "Experiences" }
      subcategory { "Books" }
      metadata { { "author" => "Cormac McCarthy", "genre" => "Fiction", "publisher" => "Vintage", "year" => "2006" } }
    end
  end
end
