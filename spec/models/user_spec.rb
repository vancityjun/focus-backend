require 'rails_helper'
require 'shoulda/matchers'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:groups).with_foreign_key(:owner_id) }
    it { is_expected.to have_many(:attenables).class_name('Attendee').with_foreign_key(:attendee_id) }
    it { is_expected.to have_many(:attended_groups).through(:attenables) }
    it { is_expected.to have_many(:permissions) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_presence_of :password }
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :last_name }
  end

  describe '.full_name' do
    subject { create :user }
    let!(:full_name) { 'Jun Lee' }

    it { expect(subject.full_name).to eq full_name }
  end

  describe '.for_token' do
    subject { create :user }
    let!(:token) do
      {
        user_id: subject.id,
        user_email: subject.email
      }
    end

    it { expect(subject.for_token).to eq token }
  end
end
