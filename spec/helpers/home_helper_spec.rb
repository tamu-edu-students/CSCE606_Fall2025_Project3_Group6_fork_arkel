require "rails_helper"

RSpec.describe HomeHelper, type: :helper do
  describe "#watch_label" do
    let(:user) { create(:user) }
    let(:movie) { create(:movie) }

    it "returns 'Watched' for non watch log activities" do
      review = create(:review, user: user, movie: movie, body: "Solid movie!", rating: 7)
      expect(helper.watch_label(review)).to eq("Watched")
    end

    it "returns 'Watched' for first watch log" do
      watch_history = create(:watch_history, user: user)
      first_log = create(:watch_log, watch_history: watch_history, movie: movie, watched_on: Date.today)

      expect(helper.watch_label(first_log)).to eq("Watched")
    end

    it "returns 'Rewatched' when a prior watch exists" do
      watch_history = create(:watch_history, user: user)
      create(:watch_log, watch_history: watch_history, movie: movie, watched_on: 2.days.ago)
      second_log = create(:watch_log, watch_history: watch_history, movie: movie, watched_on: Date.today)

      expect(helper.watch_label(second_log)).to eq("Rewatched")
    end

    it "rescues errors and returns falsey rewatch" do
      bad_activity = double(movie_id: 1, user_id: 1, watched_on: Date.today)
      allow(WatchLog).to receive(:where).and_raise(StandardError.new("boom"))
      expect(helper.watch_label(bad_activity)).to eq("Watched")
    end
  end
end
