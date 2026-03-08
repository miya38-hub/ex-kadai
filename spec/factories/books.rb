FactoryBot.define do
  factory :book do
    title { Faker::Lorem.characters(number: 5) }
    body { Faker::Lorem.characters(number: 20) }
    category { "技術" }
    score { 4.0 }
    association :user
  end
end