class FamilyTaskPoint < ApplicationRecord
  # アソシエーション
  belongs_to :family
  belongs_to :task

  # バリデーション
  validates :points, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :family_id, uniqueness: { scope: :task_id, message: "とタスクの組み合わせは既に存在します" }

  # スコープ
  # @param family_id [Integer] 家族ID
  # @return [ActiveRecord::Relation] 指定された家族のタスクポイントのコレクション
  scope :by_family, ->(family_id) { where(family_id: family_id) }

  # @param task_id [Integer] タスクID
  # @return [ActiveRecord::Relation] 指定されたタスクのポイント設定のコレクション
  scope :by_task, ->(task_id) { where(task_id: task_id) }
end

