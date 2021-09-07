FactoryBot.define do
  factory :group do
    owner { association :user }
    sequence(:name) { |n| "Group-#{n}"}
    description { 'Group description'}
    slots { 5 }
    country { 'Canada' }
    region { 'West' }
    city { 'Vancouver' }
    street_address { 'Fake Street'}
    post_code { '123 456'}
  end
end
