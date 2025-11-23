FactoryBot.define do
  factory :movie_person do
    movie { nil }
    person { nil }
    role { "MyString" }
    character { "MyString" }
  end
end
