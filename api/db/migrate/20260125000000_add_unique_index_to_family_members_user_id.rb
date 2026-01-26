class AddUniqueIndexToFamilyMembersUserId < ActiveRecord::Migration[8.0]
  def change
    # 1ユーザーは1家族にしか所属できないようにする
    # 既存の複合ユニークインデックス (user_id, family_id) は残す
    add_index :family_members, :user_id, unique: true, name: 'index_family_members_on_user_id'
  end
end

