require 'rails_helper'

RSpec.describe WatchlistItem, type: :model do
  it { is_expected.to belong_to(:watchlist) }
  it { is_expected.to belong_to(:movie) }

  it "has a valid factory" do
    watchlist = create(:watchlist, user: create(:user))
    expect(build(:watchlist_item, watchlist: watchlist, movie: create(:movie))).to be_valid
  end
end
