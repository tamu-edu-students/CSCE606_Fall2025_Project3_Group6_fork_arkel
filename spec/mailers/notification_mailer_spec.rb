require "rails_helper"

RSpec.describe NotificationMailer, type: :mailer do
  describe "#send_notification" do
    let(:user) { create(:user, email: "user@example.com") }

    it "builds an email with the given message and optional url" do
      mail = described_class.send_notification(user, "Hello there", url: "https://example.com")

      expect(mail.to).to eq([ "user@example.com" ])
      expect(mail.subject).to eq("One Notification from Cinematico")
      expect(mail.body.encoded).to include("Hello there")
    end
  end
end
