require 'rails_helper'

RSpec.describe WatchLog, type: :model do
  it 'has a valid factory' do
    expect(build(:watch_log)).to be_valid
  end

  it 'validates presence of watched_on' do
    log = build(:watch_log, watched_on: nil)
    expect(log).not_to be_valid
    expect(log.errors[:watched_on]).to include("can't be blank")
  end

  it 'rejects a future watched_on date' do
    log = build(:watch_log, watched_on: Date.tomorrow)
    expect(log).not_to be_valid
    expect(log.errors[:watched_on]).to include("can't be in the future")
  end

  it "rejects logging before the movie's release date" do
    movie = create(:movie, release_date: Date.new(2025, 1, 1))
    log = build(:watch_log, movie: movie, watched_on: Date.new(2024, 12, 31))
    expect(log).not_to be_valid
    expect(log.errors[:watched_on]).to include("can't be before the movie's release date")
  end

  it 'assigns user_id from watch_history before validation' do
    hist = create(:watch_history)
    log = build(:watch_log, watch_history: hist)
    # ensure user_id is nil initially on the in-memory object
    log.user_id = nil
    log.valid?
    expect(log.user_id).to eq(hist.user_id)
  end

  describe "callbacks" do
    let(:user) { create(:user) }
    let(:movie) { create(:movie, release_date: Date.new(2020, 1, 1), runtime: 120) }
    let(:history) { create(:watch_history, user: user) }

    it "skips sync when rating cannot be resolved" do
      log = build(:watch_log, watch_history: history, movie: movie, watched_on: Date.current)
      log.incoming_rating = nil
      allow(Review).to receive(:where).and_return(Review.none)

      expect { log.save! }.not_to change(Log, :count)
    end

    it "syncs to Log with incoming_rating" do
      log = build(:watch_log, watch_history: history, movie: movie, watched_on: Date.current)
      log.incoming_rating = 7

      expect { log.save! }.to change(Log, :count).by(1)
      synced = Log.last
      expect(synced.rating).to eq(7)
      expect(synced.rewatch).to eq(false)
    end

    it "detects rewatch when prior log exists" do
      create(:log, user: user, movie: movie, watched_on: Date.yesterday, rating: 8, rewatch: true)
      log = build(:watch_log, watch_history: history, movie: movie, watched_on: Date.current, incoming_rating: 9)

      log.save!
      synced = Log.find_by(user: user, movie: movie, watched_on: Date.current)
      expect(synced.rewatch).to eq(true)
    end

    it "removes synced log on destroy" do
      log = create(:watch_log, watch_history: history, movie: movie, watched_on: Date.current, incoming_rating: 6)
      expect(Log.where(user: user, movie: movie, watched_on: log.watched_on)).to exist

      expect { log.destroy }.to change { Log.where(user: user, movie: movie, watched_on: log.watched_on).count }.from(1).to(0)
    end

    it "rescues errors when syncing to log" do
      bad_log = build(:watch_log, watch_history: history, movie: movie, watched_on: Date.current, incoming_rating: 7)
      allow(Log).to receive(:find_or_initialize_by).and_raise(StandardError.new("boom"))

      expect { bad_log.save }.not_to raise_error
    end

    it "rescues errors when removing synced log" do
      log = create(:watch_log, watch_history: history, movie: movie, watched_on: Date.current, incoming_rating: 6)
      allow(Log).to receive(:find_by).and_raise(StandardError.new("boom"))

      expect { log.destroy }.not_to raise_error
    end
  end
end
