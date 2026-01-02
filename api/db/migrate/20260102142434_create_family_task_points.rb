class CreateFamilyTaskPoints < ActiveRecord::Migration[8.0]
  def change
    create_table :family_task_points do |t|
      t.references :family, null: false, foreign_key: { on_delete: :cascade }
      t.references :task, null: false, foreign_key: { on_delete: :restrict }
      t.integer :points, null: false, default: 1

      t.timestamps
    end
    add_index :family_task_points, [:family_id, :task_id], unique: true
    add_index :family_task_points, :family_id
  end
end
