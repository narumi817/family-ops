class Log < ApplicationRecord
  # アソシエーション
  belongs_to :user
  belongs_to :task

  # バリデーション
  validates :performed_at, presence: true

  # スコープ
  # @param user_id [Integer] ユーザーID
  # @return [ActiveRecord::Relation] 指定されたユーザーのログのコレクション
  scope :by_user, ->(user_id) { where(user_id: user_id) }

  # @param task_id [Integer] タスクID
  # @return [ActiveRecord::Relation] 指定されたタスクのログのコレクション
  scope :by_task, ->(task_id) { where(task_id: task_id) }

  # @param start_date [DateTime, Date] 開始日時
  # @param end_date [DateTime, Date] 終了日時
  # @return [ActiveRecord::Relation] 指定された日付範囲のログのコレクション
  scope :by_date_range, ->(start_date, end_date) { where(performed_at: start_date..end_date) }

  # @return [ActiveRecord::Relation] 実行日時の降順でソートされたログのコレクション
  scope :recent, -> { order(performed_at: :desc) }
end

