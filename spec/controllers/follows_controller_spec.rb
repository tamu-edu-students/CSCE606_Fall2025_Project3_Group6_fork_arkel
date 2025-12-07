require 'rails_helper'

RSpec.describe FollowsController, type: :controller do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  before do
    sign_in user
  end

  describe 'POST #create' do
    context 'when following another user' do
      it 'creates a follow relationship' do
        expect {
          post :create, params: { user_id: other_user.id }
        }.to change(Follow, :count).by(1)
      end

      it 'creates a notification for the followed user' do
        expect {
          post :create, params: { user_id: other_user.id }
        }.to change(Notification, :count).by(1)
      end

      it 'redirects back to the user profile' do
        post :create, params: { user_id: other_user.id }
        expect(response).to redirect_to(user_path(other_user))
      end

      it 'does not create duplicate follow relationships' do
        create(:follow, follower: user, followed: other_user)
        expect {
          post :create, params: { user_id: other_user.id }
        }.not_to change(Follow, :count)
      end
    end

    context 'when trying to follow self' do
      it 'does not create a follow relationship' do
        expect {
          post :create, params: { user_id: user.id }
        }.not_to change(Follow, :count)
      end

      it 'redirects with an alert message' do
        post :create, params: { user_id: user.id }
        expect(response).to redirect_to(user_path(user))
        expect(flash[:alert]).to eq("You cannot follow yourself.")
      end
    end

    context 'when not authenticated' do
      before do
        sign_out user
      end

      it 'redirects to sign in' do
        post :create, params: { user_id: other_user.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      create(:follow, follower: user, followed: other_user)
    end

    it 'destroys the follow relationship' do
      expect {
        delete :destroy, params: { user_id: other_user.id }
      }.to change(Follow, :count).by(-1)
    end

    it 'redirects back to the user profile' do
      delete :destroy, params: { user_id: other_user.id }
      expect(response).to redirect_to(user_path(other_user))
    end

    it 'removes the user from followed_users' do
      delete :destroy, params: { user_id: other_user.id }
      expect(user.followed_users).not_to include(other_user)
    end

    context 'when not authenticated' do
      before do
        sign_out user
      end

      it 'redirects to sign in' do
        delete :destroy, params: { user_id: other_user.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
