require "rails_helper"

RSpec.describe NotificationPreferencesController, type: :controller do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET #edit" do
    context "when preference does not exist" do
      before { user.notification_preference&.destroy }

      it "creates a preference and assigns it" do
        expect {
          get :edit
        }.to change(NotificationPreference, :count).by(1)

        user.reload
        expect(assigns(:preference)).to eq(user.notification_preference)
        expect(response).to have_http_status(:success)
      end
    end

    context "when preference exists" do
      it "assigns the preference" do
        get :edit

        expect(assigns(:preference)).to eq(user.notification_preference)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH #update" do
    it "updates the preference and redirects with notice" do
      patch :update, params: { notification_preference: { review_created: false, email_notifications: false } }

      expect(response).to redirect_to(edit_notification_preferences_path)
      expect(flash[:notice]).to eq("Notification preferences updated successfully.")
      expect(user.notification_preference.reload.review_created).to be(false)
      expect(user.notification_preference.email_notifications).to be(false)
    end

    it "renders edit with unprocessable status on failure" do
      pref = user.notification_preference
      allow(pref).to receive(:update).and_return(false)
      allow(controller).to receive(:current_user).and_return(user)

      patch :update, params: { notification_preference: { review_created: true } }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "authentication" do
    it "redirects unauthenticated users" do
      sign_out user

      get :edit

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
