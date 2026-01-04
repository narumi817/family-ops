class AddFamilyIdToTasks < ActiveRecord::Migration[8.0]
  def change
    # family_idをnullableにする（NULLの場合は全家族共通のタスク）
    add_reference :tasks, :family, null: true, foreign_key: { on_delete: :cascade }
  end
end
