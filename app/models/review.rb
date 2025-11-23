class Review < ApplicationRecord
  belongs_to :user
  belongs_to :movie
  has_many :votes, dependent: :destroy

  validates :body, presence: true, length: { minimum: 10 }
  validates :rating, presence: true, inclusion: { in: 1..10 }
  validates :user_id, uniqueness: { scope: :movie_id }

  scope :by_date, -> { order(created_at: :desc) }
  scope :by_score, -> { order(cached_score: :desc) }

  def score
    cached_score || 0
  end

  def update_score!
    update(cached_score: votes.sum(:value))
  end
end
