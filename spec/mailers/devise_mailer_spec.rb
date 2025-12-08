require "rails_helper"

RSpec.describe DeviseMailer, type: :mailer do
  it "inherits from ApplicationMailer" do
    expect(described_class.ancestors).to include(ApplicationMailer)
  end
end
