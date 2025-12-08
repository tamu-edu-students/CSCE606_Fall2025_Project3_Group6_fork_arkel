require "rails_helper"

RSpec.describe Log, type: :model do
  let(:movie) { create(:movie, release_date: Date.new(2020, 1, 1)) }
  let(:user) { create(:user) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:movie) }
  it { is_expected.to validate_presence_of(:rating) }
  it { is_expected.to validate_inclusion_of(:rating).in_range(1..10) }
  it { is_expected.to validate_presence_of(:watched_on) }

  it "rejects watched_on before release" do
    log = build(:log, user: user, movie: movie, watched_on: Date.new(2019, 12, 31), rating: 7)
    expect(log).not_to be_valid
    expect(log.errors[:watched_on]).to include("can't be before the movie's release date")
  end

  it "accepts watched_on on or after release" do
    log = build(:log, user: user, movie: movie, watched_on: Date.new(2020, 1, 1), rating: 7)
    expect(log).to be_valid
  end
end
