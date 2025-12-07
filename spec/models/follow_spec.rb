require 'rails_helper'

RSpec.describe Follow, type: :model do
  describe 'associations' do
    it { should belong_to(:follower).class_name('User') }
    it { should belong_to(:followed).class_name('User') }
  end

  describe 'validations' do
    let(:follower) { create(:user) }
    let(:followed) { create(:user) }

    it 'validates uniqueness of follower_id scoped to followed_id' do
      create(:follow, follower: follower, followed: followed)
      duplicate_follow = build(:follow, follower: follower, followed: followed)
      expect(duplicate_follow).not_to be_valid
      expect(duplicate_follow.errors[:follower_id]).to be_present
    end

    it 'allows same follower to follow different users' do
      followed2 = create(:user)
      create(:follow, follower: follower, followed: followed)
      follow2 = build(:follow, follower: follower, followed: followed2)
      expect(follow2).to be_valid
    end

    it 'allows different followers to follow the same user' do
      follower2 = create(:user)
      create(:follow, follower: follower, followed: followed)
      follow2 = build(:follow, follower: follower2, followed: followed)
      expect(follow2).to be_valid
    end
  end

  describe 'preventing self-follow' do
    let(:user) { create(:user) }

    it 'can be created with different follower and followed' do
      followed = create(:user)
      follow = build(:follow, follower: user, followed: followed)
      expect(follow).to be_valid
    end
  end
end
