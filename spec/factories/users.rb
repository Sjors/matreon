FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password "password"
    password_confirmation { password }
    sequence(:podcast_token) { |n| "token_#{n}" }
  end
end
