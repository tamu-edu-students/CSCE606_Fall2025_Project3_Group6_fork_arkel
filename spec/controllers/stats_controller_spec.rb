require 'rails_helper'

RSpec.describe StatsController, type: :controller do
  let(:user) { create(:user) }
  let(:stats_service) { instance_double(StatsService) }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
    allow(StatsService).to receive(:new).with(user).and_return(stats_service)
  end

  describe "GET #show" do
    let(:overview) do
      {
        total_movies: 10,
        total_hours: 1200,
        total_reviews: 5,
        total_rewatches: 2,
        genre_breakdown: { "Action" => 5, "Drama" => 3 }
      }
    end

    let(:top_contributors) do
      {
        top_genres: [ { name: "Action", count: 5 } ],
        top_directors: [ { name: "Christopher Nolan", count: 3 } ],
        top_actors: [ { name: "Leonardo DiCaprio", count: 2 } ]
      }
    end

    let(:trend_data) do
      {
        activity_trend: [ { month: "2024-01", count: 3 } ],
        rating_trend: [ { month: "2024-01", average_rating: 4.5 } ]
      }
    end

    let(:heatmap_data) do
      { "2024-01-01" => 1, "2024-01-02" => 0 }
    end

    before do
      allow(stats_service).to receive(:calculate_overview).and_return(overview)
      allow(stats_service).to receive(:calculate_top_contributors).and_return(top_contributors)
      allow(stats_service).to receive(:calculate_trend_data).and_return(trend_data)
      allow(stats_service).to receive(:calculate_heatmap_data).and_return(heatmap_data)
    end

    context "when user is authenticated" do
      it "returns successful response" do
        get :show
        expect(response).to have_http_status(:success)
      end

      it "renders show template" do
        get :show
        expect(response).to render_template(:show)
      end

      it "calculates overview stats" do
        get :show
        expect(assigns(:overview)).to eq(overview)
        expect(stats_service).to have_received(:calculate_overview)
      end

      it "calculates top contributors" do
        get :show
        expect(assigns(:top_contributors)).to eq(top_contributors)
        expect(stats_service).to have_received(:calculate_top_contributors)
      end

      it "calculates trend data" do
        get :show
        expect(assigns(:trend_data)).to eq(trend_data)
        expect(stats_service).to have_received(:calculate_trend_data)
      end

      it "calculates heatmap data" do
        get :show
        expect(assigns(:heatmap_data)).to eq(heatmap_data)
        expect(stats_service).to have_received(:calculate_heatmap_data)
      end
    end

    context "when user is not authenticated" do
      before do
        allow(controller).to receive(:authenticate_user!).and_raise(StandardError.new("Not authenticated"))
        allow(controller).to receive(:current_user).and_return(nil)
      end

      it "requires authentication" do
        expect { get :show }.to raise_error(StandardError, "Not authenticated")
      end
    end
  end
end
