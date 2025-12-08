require "rails_helper"

RSpec.describe WatchHistoriesController, type: :controller do
  let(:user) { create(:user) }
  let(:movie) { create(:movie, runtime: 120) }
  let!(:watch_history) { create(:watch_history, user: user) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "creates watch history if missing and filters/sorts logs" do
      log1 = create(:watch_log, watch_history: watch_history, movie: movie, watched_on: Date.current, created_at: 1.day.ago)
      log2 = create(:watch_log, watch_history: watch_history, movie: movie, watched_on: Date.yesterday, created_at: 2.days.ago)

      get :index, params: { watched_from: Date.yesterday.to_s, watched_to: Date.current.to_s, sort: "watched_asc" }

      expect(assigns(:watch_logs).to_a).to eq([ log2, log1 ])
      expect(response).to have_http_status(:success)
    end

    it "ignores invalid date filters and defaults sort" do
      log = create(:watch_log, watch_history: watch_history, movie: movie, watched_on: Date.current)

      get :index, params: { watched_from: "bad-date", watched_to: "also-bad" }

      expect(assigns(:watch_logs)).to include(log)
    end

    it "gracefully handles title search with no matches" do
      create(:watch_log, watch_history: watch_history, movie: movie, watched_on: Date.current)

      get :index, params: { q: "nope" }

      expect(assigns(:watch_logs)).to be_empty
    end

    it "sorts by name descending" do
      log_a = create(:watch_log, watch_history: watch_history, movie: create(:movie, title: "Aaa"), watched_on: Date.current)
      log_b = create(:watch_log, watch_history: watch_history, movie: create(:movie, title: "Bbb"), watched_on: Date.current)

      get :index, params: { sort: "name_desc" }
      expect(assigns(:watch_logs).first).to eq(log_b)
    end

    it "sorts by name ascending" do
      log_a = create(:watch_log, watch_history: watch_history, movie: create(:movie, title: "Aaa"), watched_on: Date.current)
      log_b = create(:watch_log, watch_history: watch_history, movie: create(:movie, title: "Bbb"), watched_on: Date.current)

      get :index, params: { sort: "name_asc" }
      expect(assigns(:watch_logs).first).to eq(log_a)
    end

    it "sorts by watched_desc default fallback" do
      log_a = create(:watch_log, watch_history: watch_history, movie: movie, watched_on: Date.yesterday, created_at: 1.day.ago)
      log_b = create(:watch_log, watch_history: watch_history, movie: movie, watched_on: Date.current, created_at: 2.days.ago)
      get :index, params: { sort: "watched_desc" }
      expect(assigns(:watch_logs).first).to eq(log_b)
    end

    it "sorts watched_on asc" do
      log_a = create(:watch_log, watch_history: watch_history, movie: movie, watched_on: Date.yesterday)
      log_b = create(:watch_log, watch_history: watch_history, movie: movie, watched_on: Date.current)
      get :index, params: { sort: "watched_asc" }
      expect(assigns(:watch_logs).first).to eq(log_a)
    end
  end

  describe "POST #create" do
    it "redirects with alert when movie not found" do
      post :create, params: { movie_id: 9999 }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Movie not found")
    end

    it "creates a watch log with rating and notice" do
      post :create, params: { movie_id: movie.id, watched_on: Date.current.to_s, rating: 8 }

      expect(response).to redirect_to(movie_path(movie))
      expect(flash[:notice]).to include("Logged as watched")
      expect(watch_history.reload.watch_logs.count).to eq(1)
    end

    it "uses tmdb lookup and caches runtime when missing" do
      movie.update(runtime: nil)
      tmdb_details = { "runtime" => 140 }
      tmdb_double = instance_double(TmdbService, movie_details: tmdb_details)
      allow(controller).to receive(:tmdb_service).and_return(tmdb_double)

      post :create, params: { tmdb_id: movie.tmdb_id }

      expect(movie.reload.runtime).to eq(140)
    end

    it "writes missing cache when runtime not provided" do
      movie.update(runtime: nil)
      tmdb_double = instance_double(TmdbService, movie_details: {})
      allow(controller).to receive(:tmdb_service).and_return(tmdb_double)
      expect(Rails.cache).to receive(:write).with("movie_runtime_#{movie.tmdb_id}", :missing, expires_in: 6.hours)
      post :create, params: { tmdb_id: movie.tmdb_id }
    end

    it "rescues ensure_movie_runtime errors" do
      movie.update(runtime: nil)
      tmdb_double = instance_double(TmdbService)
      allow(tmdb_double).to receive(:movie_details).and_raise(StandardError.new("boom"))
      allow(controller).to receive(:tmdb_service).and_return(tmdb_double)
      post :create, params: { tmdb_id: movie.tmdb_id }
      expect(response).to redirect_to(movie_path(movie))
    end

    it "uses cached runtime when present" do
      movie.update(runtime: nil)
      Rails.cache.write("movie_runtime_#{movie.tmdb_id}", 150)
      post :create, params: { movie_id: movie.id }
      expect(movie.reload.runtime).to eq(150)
    end

    it "redirects with alert when save fails" do
      allow_any_instance_of(WatchLog).to receive(:save).and_return(false)
      allow_any_instance_of(WatchLog).to receive_message_chain(:errors, :full_messages, :to_sentence).and_return("could not save")
      post :create, params: { movie_id: movie.id, watched_on: Date.current.to_s }
      expect(response).to redirect_to(movie_path(movie))
      expect(flash[:alert]).to eq("could not save")
    end
  end

  describe "DELETE #destroy" do
    it "destroys existing log" do
      log = create(:watch_log, watch_history: watch_history, movie: movie)

      delete :destroy, params: { id: log.id }

      expect(response).to redirect_to(watch_histories_path)
      expect(flash[:notice]).to eq("Removed from watch history")
    end

    it "handles missing log" do
      delete :destroy, params: { id: 0 }
      expect(response).to redirect_to(watch_histories_path)
      expect(flash[:alert]).to eq("Watch history entry not found")
    end

    it "handles failed destroy" do
      log = create(:watch_log, watch_history: watch_history, movie: movie)
      allow_any_instance_of(WatchLog).to receive(:destroy).and_return(false)
      delete :destroy, params: { id: log.id }
      expect(response).to redirect_to(watch_histories_path)
    end
  end
end
