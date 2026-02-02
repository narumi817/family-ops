# 家族タスクポイントの更新を処理するService
class FamilyTaskPointService
  # タスクポイントを更新する
  # @param family [Family] 家族オブジェクト
  # @param task [Task] タスクオブジェクト
  # @param points [Integer, String, nil] ポイント数
  # @return [Hash] 結果ハッシュ（success: Boolean, family_task_point: FamilyTaskPoint | nil, errors: Array<String>）
  def self.update_points(family, task, points)
    # ポイントを整数に変換してバリデーション
    points_int = points.to_i
    # 文字列の場合、to_iで変換できない場合は0になるが、元の値が数値でない場合はエラー
    if points.nil? || (points.is_a?(String) && points.strip != points_int.to_s) || points_int < 0
      return {
        success: false,
        family_task_point: nil,
        errors: ["有効なポイント数を指定してください"]
      }
    end

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
end

