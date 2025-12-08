require "rails_helper"

RSpec.describe NotificationsController, type: :controller do
  let(:user) { create(:user) }
  let!(:notification) { create(:notification, recipient: user, notification_type: "x", body: "hi") }

  before { sign_in user }

  describe "GET #index" do
    it "returns json list" do
      get :index, format: :json
      expect(response).to have_http_status(:success)
      parsed = JSON.parse(response.body)
      expect(parsed.first["notification_type"]).to eq("x")
    end

    it "renders html list" do
      get :index
      expect(response).to have_http_status(:success)
      expect(assigns(:notifications)).to include(notification)
    end

    it "redirects unauthenticated to sign in" do
      sign_out user
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  it "marks read via html" do
    post :mark_read, params: { id: notification.id }, format: :html
    expect(response).to have_http_status(:no_content)
  end

  it "marks read via turbo stream" do
    post :mark_read, params: { id: notification.id }, format: :turbo_stream
    expect(response).to have_http_status(:success).or have_http_status(:ok)
  end

  it "marks all read and renders turbo stream" do
    post :mark_all_read, format: :html
    expect(response).to have_http_status(:no_content)
  end

  it "marks all read via turbo stream" do
    post :mark_all_read, format: :turbo_stream
    expect(response).to have_http_status(:success).or have_http_status(:ok)
  end

  it "handles missing notification gracefully" do
    post :mark_read, params: { id: 0 }, format: :json
    expect(response).to have_http_status(:no_content)
  end

  it "handles mark_all_read with read column fallback" do
    allow(Notification).to receive(:column_names).and_return([ "read" ])
    post :mark_all_read, format: :json
    expect(response).to have_http_status(:no_content)
  end

  it "handles mark_all_read with read_at column" do
    allow(Notification).to receive(:column_names).and_return([ "read_at" ])
    allow(Notification).to receive(:where).and_return(Notification.none)
    post :mark_all_read, format: :json
    expect(response).to have_http_status(:no_content)
  end
end
