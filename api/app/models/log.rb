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

  # @param user_ids [Array<Integer>] ユーザーIDの配列
  # @return [ActiveRecord::Relation] 指定されたユーザーIDのいずれかに該当するログのコレクション
  scope :for_family_users, ->(user_ids) { where(user_id: user_ids) }

  # @param date [Date, String] 日付（DateオブジェクトまたはYYYY-MM-DD形式の文字列）
  # @return [ActiveRecord::Relation] 指定された日付のログのコレクション
  scope :by_date, ->(date) {
    date = date.is_a?(String) ? Date.parse(date) : date
    where(performed_at: date.beginning_of_day..date.end_of_day)
  }

  class << self
    # 家族のログ一覧を取得する
    # @param family_user_ids [Array<Integer>] 家族のユーザーIDの配列
    # @param date [String, nil] 日付（YYYY-MM-DD形式、オプション）
    # @param start_date [String, nil] 開始日（YYYY-MM-DD形式、オプション）
    # @param end_date [String, nil] 終了日（YYYY-MM-DD形式、オプション）
    # @return [ActiveRecord::Relation] フィルタリングされたログのコレクション
    # @note 日付パースで例外が発生した場合、日付フィルタを適用せずに全件を返す
    def for_family_with_filters(family_user_ids, date: nil, start_date: nil, end_date: nil)
      logs = includes(:user, :task).for_family_users(family_user_ids)

      begin
        if date.present?
          logs = logs.by_date(date)
        elsif start_date.present? && end_date.present?
          start = Date.parse(start_date).beginning_of_day
          end_time = Date.parse(end_date).end_of_day
          logs = logs.by_date_range(start, end_time)
        elsif start_date.present?
          start = Date.parse(start_date).beginning_of_day
          logs = logs.where(performed_at: start..Time.current)
        end
      rescue ArgumentError, Date::Error
        # 日付パースで例外が発生した場合、日付フィルタを適用せずにそのまま返す
      end

      logs
    end

    # 指定されたユーザーの当日の累計ポイントを計算する
    # @param user_id [Integer] ユーザーID
    # @param family_id [Integer] 家族ID
    # @param date [Date, nil] 日付（デフォルト: 今日）
    # @return [Integer] 累計ポイント
    def today_points_for_user(user_id, family_id, date: nil)
      date ||= Date.current
      today_logs = by_user(user_id).by_date(date).includes(:task)

      today_logs.sum do |log|
        log.task.points_for_family(family_id)
      end
    end
  end
end

