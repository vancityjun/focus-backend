FactoryBot.define do
  factory :user do
    email { 'jun@example.com' }
    last_name { 'Lee' }
    first_name { 'Jun' }
    password { '12345678' }
    gender { 'male' }
    country { 'Canada' }
    region { 'West' }
    city { 'Vancouver' }

    trait :owner do
      email { 'owner@example.com' }
      last_name { 'Focus' }
      first_name { 'Admin' }
    end

    trait :attendee do
      email { 'attendee@example.com' }
      last_name { 'Focus' }
      first_name { 'Attendee' }
    end
  end
end
