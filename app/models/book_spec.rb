FactoryBot.define do
  factory :user do
    name { Faker::Lorem.characters(number: 10) }
    email_address { Faker::Internet.email }
    introduction { Faker::Lorem.characters(number: 20) }
    password { "password" }
    password_confirmation { "password" }

    after(:build) do |user|
      user.profile_image.attach(
        io: File.open(Rails.root.join("spec/images/profile_image.jpeg")),
        filename: "profile_image.jpeg",
        content_type: "image/jpeg"
      )
    end
  end
end