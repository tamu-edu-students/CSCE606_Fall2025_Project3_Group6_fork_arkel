require 'rails_helper'

RSpec.describe Review, type: :model do
  let(:user) { create(:user) }
  let(:movie) { create(:movie) }

  subject(:review) { create(:review, user: user, movie: movie, body: "Great movie indeed", rating: 8) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:movie) }
  it { is_expected.to have_many(:votes).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:body) }
  it { is_expected.to validate_length_of(:body).is_at_least(10) }
  it { is_expected.to validate_presence_of(:rating) }
  it { is_expected.to validate_inclusion_of(:rating).in_range(1..10) }
  it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:movie_id) }

  describe ".by_date" do
    it "orders reviews with the newest first" do
      older = create(:review, user: user, movie: movie, body: "Old review content", rating: 7, created_at: 2.days.ago)
      newer = create(:review, user: create(:user), movie: movie, body: "Newer review content", rating: 9, created_at: 1.day.ago)

      expect(Review.by_date.first).to eq(newer)
      expect(Review.by_date.last).to eq(older)
    end
  end

  describe ".by_score" do
    it "orders reviews by cached score descending" do
      low = create(:review, user: user, movie: movie, body: "Low score content", rating: 6, cached_score: 1)
      high = create(:review, user: create(:user), movie: movie, body: "High score content", rating: 9, cached_score: 10)

      expect(Review.by_score.first).to eq(high)
      expect(Review.by_score.last).to eq(low)
    end
  end

  describe "#score" do
    it "returns cached_score when present" do
      review.cached_score = 5
      expect(review.score).to eq(5)
    end

    it "returns 0 when cached_score is nil" do
      review.cached_score = nil
      expect(review.score).to eq(0)
    end
  end

  describe "scopes" do
    it "orders by date descending" do
      older = create(:review, user: user, movie: movie, body: "Old review content", rating: 7, created_at: 2.days.ago)
      newer = create(:review, user: create(:user), movie: movie, body: "Newer review content", rating: 9, created_at: 1.day.ago)

      expect(Review.by_date.first).to eq(newer)
      expect(Review.by_date.last).to eq(older)
    end

    it "orders by score descending" do
      low = create(:review, user: user, movie: movie, body: "Low score content", rating: 6, cached_score: 1)
      high = create(:review, user: create(:user), movie: movie, body: "High score content", rating: 9, cached_score: 10)

      expect(Review.by_score.first).to eq(high)
      expect(Review.by_score.last).to eq(low)
    end
  end

  describe "#update_score!" do
    it "updates cached_score based on votes" do
      persisted_review = create(:review, user: user, movie: movie, body: "Another review body", rating: 8, cached_score: 0)
      create(:vote, user: create(:user), review: persisted_review, value: 1)
      create(:vote, user: create(:user), review: persisted_review, value: -1)
      create(:vote, user: create(:user), review: persisted_review, value: 1)

      persisted_review.update_score!

      expect(persisted_review.reload.cached_score).to eq(1)
    end

    it "handles no votes gracefully" do
      persisted_review = create(:review, user: user, movie: movie, body: "No votes body", rating: 7, cached_score: nil)
      persisted_review.update_score!
      expect(persisted_review.cached_score).to eq(0)
    end
  end

  describe "notifications" do
    it "notifies followers when a review is created" do
      follower = create(:user)
      create(:follow, follower: follower, followed: user)
      allow(NotificationCreator).to receive(:call)

      created_review = create(:review, user: user, movie: movie, body: "Follower notification body", rating: 9)

      expect(NotificationCreator).to have_received(:call).with(
        actor: user,
        recipient: follower,
        notifiable: created_review,
        notification_type: "review.created",
        body: "#{user.username} posted a review for #{movie.title}",
        data: { movie_id: movie.id, review_id: created_review.id }
      )
    end

    it "does nothing when there are no followers" do
      allow(NotificationCreator).to receive(:call)

      create(:review, user: user, movie: movie, body: "No follower body", rating: 8)

      expect(NotificationCreator).not_to have_received(:call)
    end

    it "does not notify when user is nil" do
      allow(NotificationCreator).to receive(:call)
      review_without_user = build(:review, user: nil, movie: movie, body: "No user review", rating: 8)
      expect(review_without_user).not_to be_valid
      expect(NotificationCreator).not_to have_received(:call)
    end
  end
end
