FactoryBot.define do
  factory :email_preference do
    user { nil }
    new_follower { false }
    review_votes { false }
    followed_activity { false }
  end
end
