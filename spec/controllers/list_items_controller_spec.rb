require 'rails_helper'

RSpec.describe ListItemsController, type: :controller do
  let(:user) { create(:user) }
  let(:list) { create(:list, user: user) }
  let(:movie) { create(:movie) }

  before do
    sign_in user
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new list item' do
        expect {
          post :create, params: { list_id: list.id, movie_id: movie.id }
        }.to change(ListItem, :count).by(1)
      end

      it 'associates the movie with the list' do
        post :create, params: { list_id: list.id, movie_id: movie.id }
        expect(list.reload.movies).to include(movie)
      end

      it 'redirects back with notice' do
        post :create, params: { list_id: list.id, movie_id: movie.id }
        expect(response).to redirect_to(movie_path(movie))
        expect(flash[:notice]).to eq("Added to list.")
      end

      it 'works with selected_list_id parameter' do
        expect {
          post :create, params: { selected_list_id: list.id, movie_id: movie.id, list_id: list.id }
        }.to change(ListItem, :count).by(1)
      end
    end

    context 'with invalid parameters' do
      it 'does not create list item if list not found' do
        expect {
          post :create, params: { list_id: 99999, movie_id: movie.id }
        }.not_to change(ListItem, :count)
      end

      it 'redirects with alert if list not found' do
        post :create, params: { list_id: 99999, movie_id: movie.id }
        expect(response).to redirect_to(movies_path)
        expect(flash[:alert]).to eq("List or movie not found.")
      end

      it 'does not create list item if movie not found' do
        expect {
          post :create, params: { list_id: list.id, movie_id: 99999 }
        }.not_to change(ListItem, :count)
      end

      it 'does not allow adding duplicate movies to same list' do
        create(:list_item, list: list, movie: movie)
        expect {
          post :create, params: { list_id: list.id, movie_id: movie.id }
        }.not_to change(ListItem, :count)
      end
    end

    context 'when not authenticated' do
      before do
        sign_out user
      end

      it 'redirects to sign in' do
        post :create, params: { list_id: list.id, movie_id: movie.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when list belongs to another user' do
      let(:other_user) { create(:user) }
      let(:other_list) { create(:list, user: other_user) }

      it 'does not create list item' do
        expect {
          post :create, params: { list_id: other_list.id, movie_id: movie.id }
        }.not_to change(ListItem, :count)
      end

      it 'redirects with alert' do
        post :create, params: { list_id: other_list.id, movie_id: movie.id }
        expect(response).to redirect_to(movies_path)
        expect(flash[:alert]).to eq("List or movie not found.")
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:list_item) { create(:list_item, list: list, movie: movie) }

    it 'destroys the list item' do
      expect {
        delete :destroy, params: { id: list_item.id, list_id: list.id }
      }.to change(ListItem, :count).by(-1)
    end

    it 'redirects back with notice' do
      delete :destroy, params: { id: list_item.id, list_id: list.id }
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("Removed from list.")
    end

    context 'when list item belongs to another user' do
      let(:other_user) { create(:user) }
      let(:other_list) { create(:list, user: other_user) }
      let!(:other_list_item) { create(:list_item, list: other_list, movie: movie) }

      it 'does not destroy the list item' do
        expect {
          delete :destroy, params: { id: other_list_item.id, list_id: other_list.id }
        }.not_to change(ListItem, :count)
      end

      it 'redirects with alert' do
        delete :destroy, params: { id: other_list_item.id, list_id: other_list.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Not authorized.")
      end
    end

    context 'when not authenticated' do
      before do
        sign_out user
      end

      it 'redirects to sign in' do
        delete :destroy, params: { id: list_item.id, list_id: list.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
