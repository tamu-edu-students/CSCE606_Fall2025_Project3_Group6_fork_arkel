require "rails_helper"

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user, profile_public: true) }
  let(:other_user) { create(:user, profile_public: true) }

  describe "GET #show" do
    it "shows by id when provided" do
      sign_in user
      get :show, params: { id: other_user.id }
      expect(assigns(:user)).to eq(other_user)
      expect(response).to have_http_status(:success)
    end

    it "redirects to sign in when no user and not authenticated" do
      get :show
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to include("Please sign in")
    end

    it "redirects private profile" do
      sign_in user
      private_user = create(:user, profile_public: false)
      get :show, params: { id: private_user.id }
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET #public_profile" do
    it "renders show for public user" do
      get :public_profile, params: { username: other_user.username }
      expect(assigns(:user)).to eq(other_user)
      expect(response).to render_template(:show)
    end

    it "redirects when profile is private" do
      private_user = create(:user, profile_public: false)
      get :public_profile, params: { username: private_user.username }
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET #settings" do
    it "assigns following users" do
      sign_in user
      create(:follow, follower: user, followed: other_user)
      get :settings
      expect(assigns(:following)).to include(other_user)
    end
  end

  describe "PATCH #update" do
    it "updates profile and redirects" do
      sign_in user
      patch :update, params: { user: { username: "newname" } }
      expect(response).to redirect_to(profile_path)
      expect(user.reload.username).to eq("newname")
    end

    it "renders edit on failure" do
      sign_in user
      allow_any_instance_of(User).to receive(:update).and_return(false)
      patch :update, params: { user: { username: "" } }
      expect(response).to render_template(:edit)
    end
  end

  describe "GET #reviews" do
    it "redirects when profile is private" do
      private_user = create(:user, profile_public: false)
      sign_in user
      get :reviews, params: { username: private_user.username }
      expect(response).to redirect_to(root_path)
    end

    it "renders reviews for public profile" do
      sign_in user
      create(:review, user: other_user, movie: create(:movie), body: "Public review content", rating: 7)

      get :reviews, params: { username: other_user.username }
      expect(response).to have_http_status(:success)
      expect(assigns(:reviews)).to be_present
    end
  end
end
