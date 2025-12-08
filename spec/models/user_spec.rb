require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { create(:user) }

  it { is_expected.to have_many(:reviews).dependent(:destroy) }
  it { is_expected.to have_many(:votes).dependent(:destroy) }
  it { is_expected.to have_many(:follows).dependent(:destroy) }
  it { is_expected.to have_many(:followed_users).through(:follows) }
  it { is_expected.to have_many(:followers).through(:following_users) }
  it { is_expected.to have_many(:lists).dependent(:destroy) }
  it { is_expected.to have_many(:logs).dependent(:destroy) }
  it { is_expected.to have_one(:watchlist).dependent(:destroy) }
  it { is_expected.to have_one(:watch_history).dependent(:destroy) }
  it { is_expected.to have_many(:notifications).dependent(:destroy) }
  it { is_expected.to have_one(:notification_preference).dependent(:destroy) }
  it { is_expected.to have_one(:user_stat).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:username) }
  it { is_expected.to validate_length_of(:username).is_at_least(3).is_at_most(20) }
  it { is_expected.to allow_value("user_name1").for(:username) }
  it { is_expected.not_to allow_value("user name!").for(:username) }

  describe "username uniqueness" do
    it "is case-insensitively unique" do
      create(:user, username: "unique_name")
      dup = build(:user, username: "UNIQUE_name", email: "another@example.com")

      expect(dup).not_to be_valid
      expect(dup.errors[:username]).to include("is already taken")
    end
  end

  describe "#following?" do
    it "returns true when following the given user" do
      other = create(:user)
      create(:follow, follower: user, followed: other)

      expect(user.following?(other)).to be(true)
    end

    it "returns false when not following the given user" do
      other = create(:user)

      expect(user.following?(other)).to be(false)
    end
  end

  describe "#admin?" do
    it "is true only for user with id 1" do
      allow(user).to receive(:id).and_return(1)
      expect(user.admin?).to be(true)

      allow(user).to receive(:id).and_return(2)
      expect(user.admin?).to be(false)
    end
  end
end
