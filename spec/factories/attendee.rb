FactoryBot.define do
  factory :attendee do
    attendee { association :user }
  end
end
