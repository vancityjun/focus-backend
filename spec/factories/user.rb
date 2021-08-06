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
  end
end
