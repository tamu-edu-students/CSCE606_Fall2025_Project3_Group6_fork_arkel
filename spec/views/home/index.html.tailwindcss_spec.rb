require 'rails_helper'

RSpec.describe "home/index.html.tailwindcss", type: :view do
  it "renders the landing page copy for guests" do
    assign(:trending_movies, [])
    allow(view).to receive(:user_signed_in?).and_return(false)

    render template: "home/index"

    expect(rendered).to include("Activity Feed").or include("Your feed is empty").or include("Browse Movies")
  end
end
