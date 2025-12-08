require 'rails_helper'

RSpec.describe "watchlist_items/create.html.tailwindcss", type: :view do
  it "renders the create placeholder" do
    render template: "watchlist_items/create"

    expect(rendered).to include("WatchlistItems#create")
    expect(rendered).to include("Find me in app/views/watchlist_items/create.html.erb")
  end
end
