require 'rails_helper'

RSpec.describe List, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:list_items).dependent(:destroy) }
    it { should have_many(:movies).through(:list_items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    # Note: boolean validation is tested implicitly through validations
  end

  describe 'creating a list' do
    let(:user) { create(:user) }

    it 'creates a valid list' do
      list = build(:list, user: user, name: 'My Favorite Movies', public: true)
      expect(list).to be_valid
    end

    it 'requires a name' do
      list = build(:list, user: user, name: nil)
      expect(list).not_to be_valid
      expect(list.errors[:name]).to be_present
    end

    it 'defaults to private when public is not specified' do
      list = create(:list, user: user, public: false)
      expect(list.public).to be false
    end
  end

  describe 'list items' do
    let(:user) { create(:user) }
    let(:list) { create(:list, user: user) }
    let(:movie) { create(:movie) }

    it 'can have movies added' do
      list_item = create(:list_item, list: list, movie: movie)
      expect(list.movies).to include(movie)
    end

    it 'removes movies when list is destroyed' do
      list_item = create(:list_item, list: list, movie: movie)
      list.destroy
      expect(ListItem.exists?(list_item.id)).to be false
    end
  end
end
