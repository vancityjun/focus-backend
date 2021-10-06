FactoryBot.define do
  factory :permission do
    user { association :user }
    group { association :group }
    created_by_user { association :user }
  end
end
