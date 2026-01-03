class CreateFamilyMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :family_members do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.references :family, null: false, foreign_key: { on_delete: :cascade }
      t.integer :role, null: false, default: 0

      t.timestamps
    end
    add_index :family_members, [:user_id, :family_id], unique: true
  end
end
