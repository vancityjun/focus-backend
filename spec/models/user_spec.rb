require 'rails_helper'
require 'shoulda/matchers'

RSpec.describe User, type: :model do
	describe 'validations' do
		it { is_expected.to validate_presence_of :email }
		it { is_expected.to validate_presence_of :password }
		it { is_expected.to validate_presence_of :first_name }
		it { is_expected.to validate_presence_of :last_name }
	end

	describe '.full_name' do
		subject { create :user}
		let!(:full_name) { 'Jun Lee'}

		it { expect(subject.full_name).to eq full_name }
	end

	describe '.for_token' do
		subject { create :user}
		let!(:token) do
			{ 
				user_id: subject.id,
				user_name: subject.full_name
			}
		end

		it { expect(subject.for_token).to eq token }
	end
end
