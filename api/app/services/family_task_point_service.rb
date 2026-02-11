 # 家族タスクポイントや家族タスクの操作を処理するService
class FamilyTaskPointService
  class << self
    # タスクポイントを更新する
    # @param family [Family] 家族オブジェクト
    # @param task [Task] タスクオブジェクト
    # @param points [Integer, String, nil] ポイント数
    # @return [Hash] 結果ハッシュ（success: Boolean, family_task_point: FamilyTaskPoint | nil, errors: Array<String>）
    def update_points(family, task, points)
      parsed = parse_points(points, allow_nil_as_zero: false, max: 100)

      unless parsed[:success]
        return {
          success: false,
          family_task_point: nil,
          errors: ["有効なポイント数を指定してください"]
        }
      end

      points_int = parsed[:value]

      family_task_point = FamilyTaskPoint.find_or_initialize_by(
        family_id: family.id,
        task_id: task.id
      )
      family_task_point.points = points_int

      family_task_point.save!
      {
        success: true,
        family_task_point: family_task_point,
      }

    rescue ActiveRecord::RecordInvalid => e
      {
        success: false,
        family_task_point: nil,
        errors: e.record.errors.full_messages
      }
    end

    # 家族に紐づくタスクを作成する
    # @param family [Family] 家族オブジェクト
    # @param task_params [Hash] タスク作成用パラメータ（:name, :category, :points）
    # @return [Hash] 結果ハッシュ（success: Boolean, task: Task | nil, errors: Array<String>）
    def create_task(family, task_params)
      name = task_params[:name]
      category = task_params[:category]
      raw_points = task_params[:points]

      errors = []

      # カテゴリのバリデーション（Enumに存在するか）
      unless ::Task.categories.key?(category)
        errors << "カテゴリが不正です"
        return { success: false, task: nil, errors: errors }
      end

      # ポイントのパース＆バリデーション（0〜100、空なら0）
      parsed = parse_points(raw_points, allow_nil_as_zero: true, max: 100)
      unless parsed[:success]
        errors << (parsed[:error] || "有効なポイント数を指定してください")
        return { success: false, task: nil, errors: errors }
      end

      points = parsed[:value]
      task = ::Task.new(
        family: family,
        name: name,
        category: category,
        points: points
      )

      task.save!

      {
        success: true,
        task: task,
        errors: []
      }
    rescue ActiveRecord::RecordInvalid => e
      {
        success: false,
        task: nil,
        errors: e.record.errors.full_messages
      }
    end

    private

    # ポイント共通バリデーション
    # @param raw_points [Integer, String, nil]
    # @param allow_nil_as_zero [Boolean] nil/空文字を0として扱うか
    # @param max [Integer, nil] 上限値（nilなら上限なし）
    # @return [Hash] { success: Boolean, value: Integer | nil, error: String | nil }
    def parse_points(raw_points, allow_nil_as_zero:, max:)
      if raw_points.nil? || raw_points == ""
        return allow_nil_as_zero ? { success: true, value: 0, error: nil } : { success: false, value: nil, error: "有効なポイント数を指定してください" }
      end

      # 文字列の場合は厳密に数値判定
      if raw_points.is_a?(String)
        stripped = raw_points.strip
        return { success: false, value: nil, error: "有効なポイント数を指定してください" } if stripped.empty?

        int = stripped.to_i
        return { success: false, value: nil, error: "有効なポイント数を指定してください" } if int.to_s != stripped
      else
        int = raw_points.to_i
      end

      return { success: false, value: nil, error: "有効なポイント数を指定してください" } if int.negative?
      return { success: false, value: nil, error: "有効なポイント数を指定してください" } if max && int > max

      { success: true, value: int, error: nil }
    end
  end
end

