require 'rails_helper'
require 'shoulda/matchers'

RSpec.describe Permission, type: :model do
  let!(:owner) { create :user, :owner }
  let!(:group) { create :group, owner: owner }
  let!(:archived_group) { create :group, owner: owner, archived: true }
  let!(:attendee) { create :user, :attendee }
  let!(:archived_attendee) { create :user, :attendee, archived: true }


  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:group) }
    it { is_expected.to belong_to(:created_by_user).class_name('User')}
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :user_id }
    it { is_expected.to validate_presence_of :group_id }
    it { is_expected.to validate_presence_of :created_by_user_id }

    describe '.validate_group' do
      context 'archived group' do
        subject { described_class.new user: attendee, group: archived_group, created_by_user: owner }
        it 'returns false and add errors' do
          expect(subject.valid?).to eq false
          expect(subject.errors.full_messages).to match_array([
            "Group Unable to add permission.",
          ])
        end
      end
    end

    describe '.validate_user' do
      context 'archived user' do
        subject { described_class.new user: archived_attendee, group: group, created_by_user: owner }
        it 'returns false and add errors' do
          expect(subject.valid?).to eq false
          expect(subject.errors.full_messages).to match_array([
            "User Unable to add permission.",
          ])
        end
      end
    end

    describe '.validate_organizer' do
      context 'User already got permission' do
        subject { described_class.new user: attendee, group: group, created_by_user: owner }
        it 'returns false and add errors' do
          create :permission, user: attendee, group: group, created_by_user: owner
          expect(subject.valid?).to eq false
          expect(subject.errors.full_messages).to match_array([
            "User Already added.",
          ])
        end
      end
    end
  end
end
