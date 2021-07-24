FactoryBot.define do
  factory :user do
    email { 'jun@example.com' }
    last_name { 'Lee' }
    first_name { 'Jun' }
    password { '1234' }
    gender { 'male' }
    country { 'Canada' }
    region { 'West' }
    city { 'Vancouver' }
  end
end
