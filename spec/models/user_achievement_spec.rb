require 'rails_helper'

RSpec.describe UserAchievement, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:achievement) }
end
