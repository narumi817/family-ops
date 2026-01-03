class ChangeFamilyMemberRoleDefault < ActiveRecord::Migration[8.0]
  def change
    # roleのデフォルト値を0（other）に変更
    change_column_default :family_members, :role, from: 4, to: 0
  end
end
