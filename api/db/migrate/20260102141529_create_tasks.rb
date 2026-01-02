class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.string :name, null: false
      t.text :description
      t.integer :category, null: false, default: 0

      t.timestamps
    end
    add_index :tasks, :category
  end
end
