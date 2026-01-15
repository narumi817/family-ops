FactoryBot.define do
  factory :family_member do
    association :user
    association :family
    role { :other }
  end
end

