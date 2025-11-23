class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :review

  validates :value, inclusion: { in: [ 1, -1 ] }
  validates :user_id, uniqueness: { scope: :review_id }

  after_commit :update_review_score

  private

  def update_review_score
    review.update_score!
  end
end
