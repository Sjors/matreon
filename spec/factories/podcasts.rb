FactoryBot.define do
  factory :podcast do
    guid "local"
    sequence(:title) { |n| "Episode #{n}" }
    sequence(:url) { |n| "https://example.com/podcast/#{title.to_param}.mp3" }
    description { Faker::Lorem.words(3).join(' ') }
    pub_date { Time.zone.today }
    external true
  end
end
