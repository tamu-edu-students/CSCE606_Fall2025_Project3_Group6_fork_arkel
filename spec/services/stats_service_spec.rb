require "rails_helper"

RSpec.describe StatsService do
  let(:user) { create(:user) }
  let(:tmdb_service) { instance_double(TmdbService, movie_details: { "runtime" => 140 }) }
  let(:service) { described_class.new(user, tmdb_service: tmdb_service) }

  let(:genre) { create(:genre, name: "Action") }
  let(:movie1) { create(:movie, runtime: 120, release_date: Date.new(2020, 1, 1)) }
  let(:movie2) { create(:movie, runtime: nil, tmdb_id: 999, release_date: Date.new(2010, 5, 5)) }
  let!(:movie_genre1) { create(:movie_genre, movie: movie1, genre: genre) }
  let!(:movie_genre2) { create(:movie_genre, movie: movie2, genre: genre) }

  let!(:watch_history) { create(:watch_history, user: user) }
  let!(:log1) { create(:watch_log, watch_history: watch_history, movie: movie1, watched_on: Date.new(Date.current.year, 1, 1)) }
  let!(:log2) { create(:watch_log, watch_history: watch_history, movie: movie1, watched_on: Date.new(Date.current.year, 1, 2)) }
  let!(:log3) { create(:watch_log, watch_history: watch_history, movie: movie2, watched_on: Date.new(Date.current.year, 2, 1)) }
  let!(:legacy_log) { create(:log, user: user, movie: movie1, watched_on: Date.new(Date.current.year, 1, 1), rating: 7, rewatch: true) }

  describe "#calculate_overview" do
    it "returns totals and breakdowns" do
      create(:review, user: user, movie: movie1, body: "Great movie content", rating: 8)
      result = service.calculate_overview
      expect(result[:total_movies]).to eq(2)
      expect(result[:total_hours]).to be > 0
      expect(result[:total_reviews]).to eq(1)
      expect(result[:total_rewatches]).to eq(1)
      expect(result[:genre_breakdown]).to include("Action" => 3)
      expect(result[:decade_breakdown]).to include("2020s", "2010s")
    end

    it "handles string release_date in decade breakdown" do
      movie2.update(release_date: "1999-01-01")
      result = service.calculate_overview
      expect(result[:decade_breakdown]).to include("1990s")
    end

    it "rescues and returns zeros on error" do
      bad_service = described_class.new(nil)
      expect(bad_service.calculate_overview[:total_movies]).to eq(0)
    end
  end

  describe "#calculate_top_contributors" do
    it "returns top genres, directors, and actors" do
      person_dir = create(:person, name: "Director X")
      person_act = create(:person, name: "Actor Y")
      create(:movie_person, movie: movie1, person: person_dir, role: "director")
      create(:movie_person, movie: movie1, person: person_act, role: "cast")

      result = service.calculate_top_contributors
      expect(result[:top_genres].first[:name]).to eq("Action")
      expect(result[:top_directors].first[:name]).to eq("Director X")
      expect(result[:top_actors].first[:name]).to eq("Actor Y")
    end
  end

  describe "#most_watched_movies" do
    it "returns sorted movie list with counts" do
      result = service.most_watched_movies(limit: 2)
      expect(result.first[:movie]).to eq(movie1)
      expect(result.first[:watch_count]).to eq(2)
      expect(result.first[:rewatch_count]).to eq(1)
    end

    it "rescues on error and returns empty" do
      broken = described_class.new(nil)
      expect(broken.most_watched_movies).to eq([])
    end

    it "rescues and logs errors" do
      allow(service).to receive(:user_watch_logs).and_raise(StandardError.new("boom"))
      expect(service.most_watched_movies).to eq([])
    end
  end

  describe "#calculate_trend_data" do
    it "returns activity and rating trends" do
      create(:log, user: user, movie: movie1, watched_on: log1.watched_on, rating: 8)
      trends = service.calculate_trend_data(year: Date.current.year)
      expect(trends[:activity_trend]).not_to be_empty
      expect(trends[:rating_trend]).not_to be_empty
    end
  end

  describe "#calculate_heatmap_data" do
    it "fills in missing dates" do
      heatmap = service.calculate_heatmap_data(year: Date.current.year)
      expect(heatmap[Date.new(Date.current.year, 1, 1).to_s]).to eq(1)
      expect(heatmap[Date.new(Date.current.year, 1, 2).to_s]).to eq(1)
    end

    it "handles empty logs" do
      empty_service = described_class.new(create(:user))
      expect(empty_service.calculate_heatmap_data(year: Date.current.year)).not_to be_empty
    end
  end

  describe "#heatmap_years and #trend_years" do
    it "returns years with defaults" do
      expect(service.heatmap_years).to include(Date.current.year)
      expect(service.trend_years.first).to eq(Date.current.year)
    end

    it "returns current year on error" do
      allow(service).to receive(:user_watch_logs).and_raise(StandardError.new("boom"))
      allow(service).to receive(:last_five_years).and_raise(StandardError.new("boom"))
      expect(service.heatmap_years).to eq([ Date.current.year ])
      expect(service.trend_years).to eq([ Date.current.year ])
    end
  end

  describe "#resolved_runtime" do
    it "uses cached runtime and updates from tmdb when missing" do
      Rails.cache.write("movie_runtime_#{movie2.tmdb_id}", :missing)
      expect(service.send(:resolved_runtime, movie2)).to eq(0)

      Rails.cache.delete("movie_runtime_#{movie2.tmdb_id}")
      expect(service.send(:resolved_runtime, movie2)).to eq(140)
      expect(movie2.reload.runtime).to eq(140)
    end
  end

  describe "#update_runtime_from_tmdb" do
    it "memoizes runtime per movie id" do
      expect(service.send(:update_runtime_from_tmdb, movie2)).to eq(140)
      expect(service.send(:update_runtime_from_tmdb, movie2)).to eq(140) # uses cache
    end

    it "rescues errors from tmdb_service" do
      bad_tmdb = instance_double(TmdbService)
      allow(bad_tmdb).to receive(:movie_details).and_raise(StandardError.new("boom"))
      bad_service = described_class.new(user, tmdb_service: bad_tmdb)
      expect { bad_service.send(:update_runtime_from_tmdb, movie2) }.not_to change { movie2.runtime }
    end
  end
end
