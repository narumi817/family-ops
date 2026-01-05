class Task < ApplicationRecord
  # Enum定義
  enum :category, {
    childcare: 1,    # 育児
    housework: 2,    # 家事
    other: 3         # その他
  }

  # アソシエーション
  belongs_to :family, optional: true
  has_many :logs, dependent: :restrict_with_error
  has_many :family_task_points, dependent: :destroy
  has_many :families, through: :family_task_points

  # バリデーション
  validates :name, presence: true
  validates :category, presence: true
  validates :points, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # スコープ
  # @param category [Symbol, Integer] カテゴリ（:childcare, :housework, :other または 1, 2, 3）
  # @return [ActiveRecord::Relation] 指定されたカテゴリのタスクのコレクション
  scope :by_category, ->(category) { where(category: category) }

  # @return [ActiveRecord::Relation] 全家族共通のタスクのコレクション
  scope :global, -> { where(family_id: nil) }

  # @param family_id [Integer] 家族ID
  # @return [ActiveRecord::Relation] 指定された家族のタスク（全家族共通 + 家族固有）のコレクション
  scope :for_family, ->(family_id) { where(family_id: [nil, family_id]) }

  # @param family_id [Integer] 家族ID
  # @return [ActiveRecord::Relation] 指定された家族固有のタスクのコレクション
  scope :by_family, ->(family_id) { where(family_id: family_id) }

  # 指定された家族に対するタスクのポイントを取得する
  # family_task_pointsに設定がある場合はそれを優先、なければtasksのデフォルトポイントを返す
  # @param family_id [Integer] 家族ID
  # @return [Integer] ポイント数
  def points_for_family(family_id)
    family_task_point = family_task_points.find_by(family_id: family_id)
    family_task_point ? family_task_point.points : points
  end
end

