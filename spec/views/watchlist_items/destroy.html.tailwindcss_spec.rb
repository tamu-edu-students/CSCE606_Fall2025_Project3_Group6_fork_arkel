require 'rails_helper'

RSpec.describe "watchlist_items/destroy.html.tailwindcss", type: :view do
  it "renders the destroy placeholder" do
    render template: "watchlist_items/destroy"

    expect(rendered).to include("WatchlistItems#destroy")
    expect(rendered).to include("Find me in app/views/watchlist_items/destroy.html.erb")
  end
end
