require 'rails_helper'

RSpec.describe ListItem, type: :model do
  subject(:list_item) { create(:list_item) }

  it { is_expected.to belong_to(:list) }
  it { is_expected.to belong_to(:movie) }
  it { is_expected.to validate_uniqueness_of(:movie_id).scoped_to(:list_id) }
end
