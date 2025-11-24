class WatchLog < ApplicationRecord
  belongs_to :watch_history
  belongs_to :movie

  validates :watched_on, presence: true
end
