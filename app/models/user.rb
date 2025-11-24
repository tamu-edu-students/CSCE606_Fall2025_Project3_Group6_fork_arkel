class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :reviews, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :follows, foreign_key: :follower_id, dependent: :destroy
  has_many :followed_users, through: :follows, source: :followed
  has_many :following_users, foreign_key: :followed_id, class_name: "Follow", dependent: :destroy
  has_many :followers, through: :following_users, source: :follower

  has_one :watchlist, dependent: :destroy
  has_one :watch_history, dependent: :destroy

  def admin?
    id == 1
  end
end
