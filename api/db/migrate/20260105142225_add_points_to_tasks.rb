class AddPointsToTasks < ActiveRecord::Migration[8.0]
  def change
    add_column :tasks, :points, :integer, null: false, default: 1
  end
end
