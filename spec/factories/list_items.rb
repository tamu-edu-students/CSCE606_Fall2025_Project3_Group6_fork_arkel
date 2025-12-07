FactoryBot.define do
  factory :list_item do
    association :list
    association :movie
  end
end
