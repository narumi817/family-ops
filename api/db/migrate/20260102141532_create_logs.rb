class CreateLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :logs do |t|
      t.references :user, null: false, foreign_key: { on_delete: :restrict }
      t.references :task, null: false, foreign_key: { on_delete: :restrict }
      t.datetime :performed_at, null: false
      t.text :notes

      t.timestamps
    end
    add_index :logs, :performed_at
    add_index :logs, [:user_id, :performed_at]
    add_index :logs, [:task_id, :performed_at]
  end
end
