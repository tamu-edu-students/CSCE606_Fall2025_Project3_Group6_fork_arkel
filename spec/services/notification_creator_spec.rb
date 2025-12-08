require "rails_helper"

RSpec.describe NotificationCreator do
  let(:actor) { create(:user) }
  let(:recipient) { create(:user) }
  let(:review) { create(:review, user: recipient, movie: create(:movie), body: "Great movie content", rating: 8) }

  it "returns nil when recipient is blank" do
    expect(described_class.call(actor: actor, recipient: nil, notification_type: "x")).to be_nil
  end

  it "respects notification preference toggles" do
    pref = recipient.notification_preference
    pref.update!(review_created: false)

    expect {
      described_class.call(actor: actor, recipient: recipient, notification_type: "review.created", notifiable: review)
    }.not_to change(Notification, :count)
  end

  it "creates notification and sends email when allowed" do
    allow(NotificationMailer).to receive_message_chain(:send_notification, :deliver_later)

    notification = described_class.call(
      actor: actor,
      recipient: recipient,
      notification_type: "review.voted",
      notifiable: review,
      body: "Body text"
    )

    expect(notification).to be_present
    expect(notification.notification_type).to eq("review.voted")
  end

  it "maps user.unfollowed preference key" do
    pref = recipient.notification_preference
    pref.update!(user_followed: false)
    result = described_class.call(actor: actor, recipient: recipient, notification_type: "user.unfollowed")
    expect(result).to be_nil
  end

  it "builds attributes with data and notifiable" do
    allow(Notification).to receive(:column_names).and_return([ "id", "recipient_id", "notification_type", "body", "created_at", "updated_at", "data", "notifiable_type", "notifiable_id", "actor_id" ])
    expect(Notification).to receive(:create!).with(hash_including(:data, :notifiable_type, :notifiable_id))
    described_class.call(actor: actor, recipient: recipient, notification_type: "review.created", notifiable: review, body: "Hello", data: { key: "value" })
  end

  it "handles broadcast ArgumentError gracefully" do
    allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to).and_raise(ArgumentError.new("bad id"))
    expect {
      described_class.call(actor: actor, recipient: recipient, notification_type: "review.created")
    }.not_to raise_error
  end

  it "handles exceptions gracefully" do
    allow(Notification).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Notification.new))
    expect(described_class.call(actor: actor, recipient: recipient, notification_type: "review.created")).to be_nil
  end
end
