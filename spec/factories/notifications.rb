FactoryBot.define do
  factory :notification do
    association :recipient, factory: :user
    association :actor, factory: :user
    notification_type { "notification.test" }
    notifiable_type { "Review" }
    notifiable_id { 1 }
    read { false }
    body { "Test notification" }
  end
end
