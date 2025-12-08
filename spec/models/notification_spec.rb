require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:recipient) { create(:user) }
  let(:actor) { create(:user) }
  let(:movie) { create(:movie) }
  let(:review) { create(:review, user: recipient, movie: movie, body: "Nice flick!", rating: 7) }

  subject(:notification) do
    described_class.new(
      recipient: recipient,
      actor: actor,
      notification_type: "review.created",
      notifiable: review,
      body: "Test notification"
    )
  end

  it { is_expected.to belong_to(:recipient).class_name("User") }
  it { is_expected.to belong_to(:actor).class_name("User").optional }
  it { is_expected.to belong_to(:notifiable).optional }

  it { is_expected.to validate_presence_of(:notification_type) }

  describe "scopes" do
    it "returns unread notifications" do
      unread = create(:notification, recipient: recipient, notification_type: "x", read: false, body: "Unread")
      create(:notification, recipient: recipient, notification_type: "x", read: true, body: "Read")

      expect(Notification.unread).to contain_exactly(unread)
    end

    it "returns read notifications" do
      create(:notification, recipient: recipient, notification_type: "x", read: false, body: "Unread")
      read = create(:notification, recipient: recipient, notification_type: "x", read: true, body: "Read")

      expect(Notification.read).to contain_exactly(read)
    end

    it "falls back when read columns missing" do
      allow(Notification).to receive(:column_names).and_return([])
      expect(Notification.unread.where_values_hash).to eq({})
      expect(Notification.read.where_values_hash).to eq({})
    end

    it "uses read_at column when present" do
      allow(Notification).to receive(:column_names).and_return([ "read_at" ])
      expect(Notification.unread.to_sql).to include("read_at")
      expect(Notification.read.to_sql).to include("read_at")
    end
  end

  describe "#mark_as_read!" do
    it "marks the notification as read" do
      notification.save!
      expect { notification.mark_as_read! }.to change(notification, :read?).from(false).to(true)
    end

    it "is a no-op when already read" do
      notification.read = true
      notification.save!
      expect { notification.mark_as_read! }.not_to change(notification, :read?)
    end

    it "returns true when no read columns" do
      notification.save!
      allow(notification).to receive(:has_attribute?).with(:read_at).and_return(false)
      allow(notification).to receive(:has_attribute?).with(:read).and_return(false)
      expect(notification.mark_as_read!).to eq(true)
    end

    it "updates read_at when present" do
      notification.save!
      # Define read_at accessor for partial double verification
      notification.define_singleton_method(:read_at) { @read_at }
      notification.define_singleton_method(:read_at=) { |val| @read_at = val }
      allow(notification).to receive(:has_attribute?).with(:read_at).and_return(true)
      expect(notification).to receive(:update!).with(read_at: kind_of(Time))
      notification.mark_as_read!
    end
  end

  describe "#mark_as_unread!" do
    it "marks the notification as unread" do
      notification.read = true
      notification.save!

      expect { notification.mark_as_unread! }.to change(notification, :read?).from(true).to(false)
    end

    it "is a no-op when already unread" do
      notification.save!
      expect { notification.mark_as_unread! }.not_to change(notification, :read?)
    end

    it "returns true when no read columns" do
      notification.save!
      allow(notification).to receive(:has_attribute?).with(:read_at).and_return(false)
      allow(notification).to receive(:has_attribute?).with(:read).and_return(false)
      allow(notification).to receive(:read?).and_return(true)
      expect(notification.mark_as_unread!).to eq(true)
    end

    it "updates read_at when present" do
      notification.read = true
      notification.save!
      notification.define_singleton_method(:read_at) { @read_at || Time.current }
      notification.define_singleton_method(:read_at=) { |val| @read_at = val }
      allow(notification).to receive(:has_attribute?).with(:read_at).and_return(true)
      expect(notification).to receive(:update!).with(read_at: nil)
      notification.mark_as_unread!
    end
  end

  describe "#mark_delivered!" do
    it "returns true even when delivered_at column is absent" do
      notification.save!
      expect(notification.mark_delivered!).to be true
    end

    it "updates delivered_at when present" do
      notification.save!
      # Define delivered_at reader for partial double verification
      notification.define_singleton_method(:delivered_at) { @delivered_at }
      notification.define_singleton_method(:delivered_at=) { |val| @delivered_at = val }
      allow(notification).to receive(:has_attribute?).with(:delivered_at).and_return(true)
      expect(notification).to receive(:update!).with(delivered_at: kind_of(Time))
      notification.mark_delivered!
    end
  end

  describe "#as_json" do
    it "includes recipient key and allowed attributes" do
      notification.save!
      json = notification.as_json

      expect(json).to include("user_id")
      expect(json).to include("notification_type")
      expect(json).to include("body")
    end

    it "respects delivered_at/read_at columns when present" do
      notification.read_at = Time.current if notification.respond_to?(:read_at)
      notification.delivered_at = Time.current if notification.respond_to?(:delivered_at)
      notification.save!

      json = notification.as_json
      if notification.respond_to?(:read_at)
        expect(json).to include("read_at")
      end
      if notification.respond_to?(:delivered_at)
        expect(json).to include("delivered_at")
      end
    end

    it "handles schemas using recipient_id without raising" do
      notification.save!
      allow(Notification).to receive(:column_names).and_return([ "id", "recipient_id", "notification_type", "body", "created_at", "updated_at" ])
      json = notification.as_json
      expect(json).to be_a(Hash)
      expect(json["notification_type"]).to eq("review.created")
    end
  end

  describe "#payload" do
    if Notification.column_names.include?("data")
      it "returns a hash when data is nil" do
        notification.data = nil
        expect(notification.payload).to eq({})
      end

      it "returns the data when present" do
        notification.data = { foo: "bar" }
        expect(notification.payload.symbolize_keys).to eq({ foo: "bar" })
      end
    else
      it "returns an empty hash when data column is absent" do
        expect(notification.payload).to eq({})
      end
    end

    it "returns empty hash when data column missing (fallback branch)" do
      allow(notification).to receive(:has_attribute?).with(:data).and_return(false)
      expect(notification.payload).to eq({})
    end
  end
end
