require 'rails_helper'

RSpec.describe LogTag, type: :model do
  it { is_expected.to belong_to(:log) }
  it { is_expected.to belong_to(:tag) }
end
