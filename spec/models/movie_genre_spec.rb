require 'rails_helper'

RSpec.describe MovieGenre, type: :model do
  it { is_expected.to belong_to(:movie) }
  it { is_expected.to belong_to(:genre) }
end
