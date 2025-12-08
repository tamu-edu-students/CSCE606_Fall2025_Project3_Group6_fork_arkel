require "rails_helper"

RSpec.describe WatchlistItemsController, type: :controller do
  let(:user) { create(:user) }
  let(:watchlist) { create(:watchlist, user: user) }
  let(:movie) { create(:movie) }

  before { sign_in user }

  describe "POST #create" do
    it "redirects with alert when movie missing" do
      post :create, params: { watchlist_item: { watchlist_id: watchlist.id, movie_id: nil } }
      expect(response).to redirect_to(movies_path)
      expect(flash[:alert]).to be_present
    end

    it "redirects notice when already in watchlist" do
      create(:watchlist_item, watchlist: watchlist, movie: movie)
      post :create, params: { movie_id: movie.id }
      expect(response).to redirect_to(watchlist_path)
      expect(flash[:notice]).to include("Already in watchlist")
    end

    it "restores movie and handles already present case" do
      create(:watchlist_item, watchlist: watchlist, movie: movie)
      post :restore, params: { movie_id: movie.id }
      expect(response).to redirect_to(watchlist_path)
      expect(flash[:notice]).to include("Movie already in watchlist")
    end
  end

  describe "DELETE #destroy" do
    it "redirects when item not found" do
      delete :destroy, params: { id: 0 }
      expect(response).to redirect_to(watchlist_path)
      expect(flash[:alert]).to be_present
    end

    it "redirects with notice on success" do
      item = create(:watchlist_item, watchlist: watchlist, movie: movie)
      delete :destroy, params: { id: item.id }
      expect(response).to redirect_to(watchlist_path)
      expect(flash[:notice]).to be_present
    end

    it "redirects with alert when destroy fails" do
      item = create(:watchlist_item, watchlist: watchlist, movie: movie)
      allow_any_instance_of(WatchlistItem).to receive(:destroy).and_return(false)
      delete :destroy, params: { id: item.id }
      expect(response).to redirect_to(watchlist_path)
      expect(flash[:alert]).to include("Could not remove")
    end
  end
end
