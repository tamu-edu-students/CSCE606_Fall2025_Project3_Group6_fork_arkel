require 'rails_helper'

RSpec.describe MoviePerson, type: :model do
  it { is_expected.to belong_to(:movie) }
  it { is_expected.to belong_to(:person) }
end
