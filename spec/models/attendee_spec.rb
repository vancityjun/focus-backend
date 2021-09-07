require 'rails_helper'
require 'shoulda/matchers'

RSpec.describe Attendee, type: :model do
  let!(:owner) { create :user}
  let!(:user) { create :user, first_name: 'Vince', last_name: 'Yoon', email: 'vince@example.com'}
  let!(:group) { create :group, owner: owner }

  describe 'associations' do
    it { is_expected.to belong_to :resource }
    it { is_expected.to belong_to(:attendee).class_name('User') }
  end

  describe '.valid_attendee' do
    describe 'not join yet' do
      subject { build :attendee, attendee: user, resource: group }
      it 'validation passed' do
        expect(subject).to be_valid
      end
    end

    describe 'already joined' do
      subject { build :attendee, attendee: owner, resource: group }
      it 'validation failed' do
        expect(subject).to be_invalid
        expect(subject.errors.full_messages).to match(
          ["Already Join the Group"]
        )
      end
    end
  end
end
