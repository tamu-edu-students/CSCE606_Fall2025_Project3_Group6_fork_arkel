require "rails_helper"

RSpec.describe WatchlistsController, type: :controller do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET #show" do
    context "when the user has no watchlist" do
      before { user.watchlist&.destroy }

      it "creates and assigns a watchlist" do
        expect {
          get :show
        }.to change(Watchlist, :count).by(1)

        user.reload
        expect(assigns(:watchlist)).to eq(user.watchlist)
        expect(assigns(:items)).to eq(user.watchlist.watchlist_items)
        expect(response).to have_http_status(:success)
      end
    end

    context "when the user already has a watchlist" do
      let!(:existing) { create(:watchlist, user: user) }

      it "reuses the existing watchlist" do
        expect {
          get :show
        }.not_to change(Watchlist, :count)

        expect(assigns(:watchlist)).to eq(existing)
      end
    end
  end

  describe "authentication" do
    it "redirects unauthenticated users" do
      sign_out user

      get :show

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
