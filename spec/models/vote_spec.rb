require 'rails_helper'

RSpec.describe Vote, type: :model do
  let(:user) { create(:user) }
  let(:review_author) { create(:user) }
  let(:movie) { create(:movie) }
  let(:review) { create(:review, user: review_author, movie: movie, body: "Great movie!" * 2, rating: 8) }

  subject(:vote) { create(:vote, user: user, review: review, value: 1) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:review) }
  it { is_expected.to validate_inclusion_of(:value).in_array([ 1, -1 ]) }
  it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:review_id) }

  describe "callbacks" do
    let(:new_vote) { build(:vote, user: user, review: review, value: 1) }

    it "updates the review score after commit" do
      allow(review).to receive(:update_score!)

      new_vote.save!

      expect(review).to have_received(:update_score!)
    end

    it "notifies the review author when someone else votes" do
      allow(NotificationCreator).to receive(:call)

      new_vote.save!

      expect(NotificationCreator).to have_received(:call).with(
        actor: user,
        recipient: review_author,
        notifiable: review,
        notification_type: "review.voted",
        body: "#{user.username} liked your review of #{movie.title}"
      )
    end

    it "does not notify when the author votes on their own review" do
      own_review = create(:review, user: user, movie: movie, body: "Self review" * 2, rating: 7)
      allow(NotificationCreator).to receive(:call)

      create(:vote, user: user, review: own_review, value: 1)

      expect(NotificationCreator).not_to have_received(:call)
    end
  end
end
