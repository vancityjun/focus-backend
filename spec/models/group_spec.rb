require 'rails_helper'
require 'shoulda/matchers'

RSpec.describe Group, type: :model do
  let!(:owner) { create :user}

  describe 'associations' do
    it { is_expected.to belong_to(:owner).class_name('User')}
    it { is_expected.to have_many(:attenables).class_name('Attendee') }
    it { is_expected.to have_many(:attendees).through(:attenables) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :slots }
  end

  describe 'scope' do
    describe '.find_public' do
      let!(:public_group) { create :group, owner: owner }
      let!(:private_group) { create :group, owner: owner, private: true }
      it 'limits to current scope' do
        expect(owner.groups.find_public).to match_array([
          public_group,
        ])
      end
    end
  end
end
