require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the WatchlistItemsHelper. For example:
#
# describe WatchlistItemsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe WatchlistItemsHelper, type: :helper do
  it "is available in the view context" do
    expect(helper).to be_a(WatchlistItemsHelper)
  end
end
