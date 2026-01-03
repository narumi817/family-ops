class Task < ApplicationRecord
  # Enum定義
  enum :category, {
    childcare: 1,    # 育児
    housework: 2,    # 家事
    other: 3         # その他
  }

  # アソシエーション
  has_many :logs, dependent: :restrict_with_error
  has_many :family_task_points, dependent: :destroy
  has_many :families, through: :family_task_points

  # バリデーション
  validates :name, presence: true
  validates :category, presence: true

  # スコープ
  # @param category [Symbol, Integer] カテゴリ（:childcare, :housework, :other または 1, 2, 3）
  # @return [ActiveRecord::Relation] 指定されたカテゴリのタスクのコレクション
  scope :by_category, ->(category) { where(category: category) }
end

