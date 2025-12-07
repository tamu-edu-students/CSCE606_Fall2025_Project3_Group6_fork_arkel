FactoryBot.define do
  factory :watch_log do
    association :movie
    association :watch_history
    watched_on { Date.current }
  end
end
