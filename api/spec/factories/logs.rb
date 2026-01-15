FactoryBot.define do
  factory :log do
    association :user
    association :task
    performed_at { Time.current }
    notes { nil }
  end
end

