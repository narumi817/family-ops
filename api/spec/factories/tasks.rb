FactoryBot.define do
  factory :task do
    name { "テストタスク" }
    description { "テスト用のタスクです" }
    category { :housework }
    points { 10 }
  end
end

