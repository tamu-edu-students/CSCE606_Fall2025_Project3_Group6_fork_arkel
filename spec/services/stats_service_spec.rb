require 'rails_helper'

RSpec.describe StatsService, type: :service do
  let(:user) { create(:user) }
  let(:service) { described_class.new(user) }

  describe "#calculate_overview" do
    context "with logged movies" do
      let!(:movie1) { create(:movie, title: "Inception", runtime: 148) }
      let!(:movie2) { create(:movie, title: "The Matrix", runtime: 136) }
      let!(:genre) { create(:genre, name: "Action") }
      let!(:log1) { create(:log, user: user, movie: movie1, watched_on: 1.month.ago, rating: 5, rewatch: false) }
      let!(:log2) { create(:log, user: user, movie: movie2, watched_on: 2.weeks.ago, rating: 4, rewatch: true) }

      before do
        movie1.genres << genre
        movie2.genres << genre
      end

      it "calculates total movies correctly" do
        overview = service.calculate_overview
        expect(overview[:total_movies]).to eq(2)
      end

      it "calculates total hours correctly" do
        overview = service.calculate_overview
        expect(overview[:total_hours]).to eq(284) # 148 + 136 minutes
      end

      it "calculates total reviews correctly" do
        create(:review, user: user, movie: movie1, body: "This is a great movie review with enough characters.")
        overview = service.calculate_overview
        expect(overview[:total_reviews]).to eq(1)
      end

      it "calculates total rewatches correctly" do
        overview = service.calculate_overview
        expect(overview[:total_rewatches]).to eq(1)
      end

      it "calculates genre breakdown correctly" do
        overview = service.calculate_overview
        expect(overview[:genre_breakdown]).to include("Action" => 2)
      end
    end

    context "with no logged movies" do
      it "returns zero values" do
        overview = service.calculate_overview
        expect(overview[:total_movies]).to eq(0)
        expect(overview[:total_hours]).to eq(0)
        expect(overview[:total_reviews]).to eq(0)
        expect(overview[:total_rewatches]).to eq(0)
        expect(overview[:genre_breakdown]).to be_empty
      end
    end

    context "with error handling" do
      before do
        allow(user).to receive(:logs).and_raise(StandardError.new("Database error"))
      end

      it "returns safe default values" do
        overview = service.calculate_overview
        expect(overview[:total_movies]).to eq(0)
        expect(overview[:total_hours]).to eq(0)
      end
    end
  end

  describe "#calculate_top_contributors" do
    let!(:movie1) { create(:movie, title: "Inception") }
    let!(:movie2) { create(:movie, title: "The Matrix") }
    let!(:genre1) { create(:genre, name: "Action") }
    let!(:genre2) { create(:genre, name: "Sci-Fi", tmdb_id: 878) }
    let!(:director) { create(:person, name: "Christopher Nolan", tmdb_id: 2) }
    let!(:actor) { create(:person, name: "Leonardo DiCaprio", tmdb_id: 3) }

    before do
      movie1.genres << genre1
      movie1.genres << genre2
      movie2.genres << genre1

      create(:movie_person, movie: movie1, person: director, role: "director")
      create(:movie_person, movie: movie1, person: actor, role: "cast")
      create(:movie_person, movie: movie2, person: director, role: "director")

      create(:log, user: user, movie: movie1)
      create(:log, user: user, movie: movie2)
    end

    it "calculates top genres" do
      contributors = service.calculate_top_contributors
      expect(contributors[:top_genres]).to be_present
      expect(contributors[:top_genres].first[:name]).to eq("Action")
      expect(contributors[:top_genres].first[:count]).to eq(2)
    end

    it "calculates top directors" do
      contributors = service.calculate_top_contributors
      expect(contributors[:top_directors]).to be_present
      expect(contributors[:top_directors].first[:name]).to eq("Christopher Nolan")
      expect(contributors[:top_directors].first[:count]).to eq(2)
    end

    it "calculates top actors" do
      contributors = service.calculate_top_contributors
      expect(contributors[:top_actors]).to be_present
      expect(contributors[:top_actors].first[:name]).to eq("Leonardo DiCaprio")
      expect(contributors[:top_actors].first[:count]).to eq(1)
    end

    it "limits results to top 10" do
      contributors = service.calculate_top_contributors
      expect(contributors[:top_genres].length).to be <= 10
      expect(contributors[:top_directors].length).to be <= 10
      expect(contributors[:top_actors].length).to be <= 10
    end
  end

  describe "#calculate_trend_data" do
    let!(:movie) { create(:movie, title: "Test Movie") }

    context "with sufficient data" do
      before do
        create(:log, user: user, movie: movie, watched_on: 3.months.ago, rating: 4)
        create(:log, user: user, movie: movie, watched_on: 2.months.ago, rating: 5)
        create(:log, user: user, movie: movie, watched_on: 1.month.ago, rating: 3)
      end

      it "calculates activity trend" do
        trend_data = service.calculate_trend_data
        expect(trend_data[:activity_trend]).to be_present
        expect(trend_data[:activity_trend].length).to eq(3)
      end

      it "calculates rating trend" do
        trend_data = service.calculate_trend_data
        expect(trend_data[:rating_trend]).to be_present
        expect(trend_data[:rating_trend].first).to have_key(:month)
        expect(trend_data[:rating_trend].first).to have_key(:average_rating)
      end

      it "calculates correct average ratings" do
        trend_data = service.calculate_trend_data
        rating_data = trend_data[:rating_trend].find { |d| d[:month] == 3.months.ago.strftime("%Y-%m") }
        expect(rating_data[:average_rating]).to eq(4.0)
      end
    end

    context "with insufficient data" do
      it "returns empty arrays" do
        trend_data = service.calculate_trend_data
        expect(trend_data[:activity_trend]).to be_empty
        expect(trend_data[:rating_trend]).to be_empty
      end
    end

    context "with logs without dates" do
      before do
        # Create log without watched_on by directly inserting
        log = Log.new(user: user, movie: movie, rating: 4)
        log.save(validate: false)
      end

      it "excludes logs without dates" do
        trend_data = service.calculate_trend_data
        expect(trend_data[:activity_trend]).to be_empty
      end
    end
  end

  describe "#calculate_heatmap_data" do
    let!(:movie) { create(:movie, title: "Test Movie") }

    context "with logs with dates" do
      before do
        create(:log, user: user, movie: movie, watched_on: 1.week.ago)
        create(:log, user: user, movie: movie, watched_on: 2.days.ago)
        create(:log, user: user, movie: movie, watched_on: Date.today)
      end

      it "calculates heatmap data" do
        heatmap = service.calculate_heatmap_data
        expect(heatmap).to be_a(Hash)
        week_ago_date = 1.week.ago.to_date.to_s
        today_date = Date.today.to_s
        expect(heatmap[week_ago_date]).to eq(1)
        expect(heatmap[today_date]).to eq(1)
      end

      it "includes all dates in range" do
        heatmap = service.calculate_heatmap_data
        start_date = 365.days.ago.to_date
        end_date = Date.today
        (start_date..end_date).each do |date|
          expect(heatmap).to have_key(date.to_s)
        end
      end

      it "counts multiple logs on same day" do
        create(:log, user: user, movie: movie, watched_on: Date.today)
        heatmap = service.calculate_heatmap_data
        expect(heatmap[Date.today.to_s]).to eq(2)
      end
    end

    context "with no logs" do
      it "returns hash with zero values for all dates" do
        heatmap = service.calculate_heatmap_data
        expect(heatmap).to be_a(Hash)
        expect(heatmap.values.all? { |v| v == 0 }).to be true
      end
    end

    context "with logs without dates" do
      before do
        # Create log without watched_on by directly inserting
        log = Log.new(user: user, movie: movie)
        log.save(validate: false)
      end

      it "excludes logs without dates" do
        heatmap = service.calculate_heatmap_data
        expect(heatmap.values.all? { |v| v == 0 }).to be true
      end
    end
  end
end
