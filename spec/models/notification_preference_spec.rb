require 'rails_helper'

RSpec.describe NotificationPreference, type: :model do
  let(:user) { create(:user) }

  before do
    # User callback creates a default preference; remove it so we can exercise validations cleanly
    user.notification_preference&.destroy
  end

  subject(:notification_preference) { build(:notification_preference, user: user) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_uniqueness_of(:user_id) }
end
