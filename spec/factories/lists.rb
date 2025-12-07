FactoryBot.define do
  factory :list do
    association :user
    name { Faker::Movie.title }
    description { Faker::Lorem.paragraph }
    public { false }
  end
end
