FactoryBot.define do
  factory :email_preference do
    association :user
    new_follower { false }
    review_votes { false }
    followed_activity { false }
  end
end
