require "rails_helper"

RSpec.describe HomeController, type: :controller do
  describe "GET #index" do
    context "when unauthenticated" do
      it "loads trending movies and renders success" do
        create_list(:movie, 5)

        get :index

        expect(assigns(:trending_movies).size).to eq(4)
        expect(response).to have_http_status(:success)
      end
    end

    context "when authenticated" do
      let(:user) { create(:user) }
      let(:followed) { create(:user) }

      before do
        sign_in user
        create(:follow, follower: user, followed: followed)
      end

      it "collects activities from followed users and paginates" do
        movie = create(:movie)
        recent_review = create(:review, user: followed, movie: movie, body: "Amazing film!", rating: 9, created_at: 1.hour.ago)
        older_vote = create(:vote, user: followed, review: recent_review, value: 1, created_at: 2.hours.ago)

        get :index

        expect(assigns(:activities)).to eq([ recent_review, older_vote ])
        expect(assigns(:page)).to eq(1)
        expect(assigns(:total_pages)).to eq(1)
        expect(assigns(:trending_movies).length).to be <= 4
      end

      it "uses page param and slices activities" do
        12.times do |i|
          movie = create(:movie, tmdb_id: i + 1000, title: "Movie #{i}")
          create(:review, user: followed, movie: movie, body: "Review #{i} content", rating: 8, created_at: i.minutes.ago, cached_score: 0)
        end

        get :index, params: { page: 2 }

        expect(assigns(:page)).to eq(2)
        expect(assigns(:activities).length).to eq(2) # second page of 10-per-page slice
        expect(assigns(:total_pages)).to eq(2)
      end
    end
  end
end
