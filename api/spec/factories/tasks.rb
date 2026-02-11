FactoryBot.define do
  factory :task do
    sequence(:name) { |n| "テストタスク#{n}" }
    description { "テスト用のタスクです" }
    category { :housework }
    points { 10 }
  end
end

