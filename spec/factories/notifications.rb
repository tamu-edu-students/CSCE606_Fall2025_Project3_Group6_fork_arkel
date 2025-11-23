FactoryBot.define do
  factory :notification do
    user { nil }
    actor_id { 1 }
    notification_type { "MyString" }
    notifiable_type { "MyString" }
    notifiable_id { 1 }
    read { false }
  end
end
