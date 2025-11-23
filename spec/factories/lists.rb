FactoryBot.define do
  factory :list do
    user { nil }
    name { "MyString" }
    description { "MyText" }
    public { false }
  end
end
