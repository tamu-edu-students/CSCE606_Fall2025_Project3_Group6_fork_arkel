require 'rails_helper'

RSpec.describe Watchlist, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:watchlist_items).dependent(:destroy) }
  it { is_expected.to have_many(:movies).through(:watchlist_items) }
end
