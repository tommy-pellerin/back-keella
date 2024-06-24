class AddCategoryIdToWorkouts < ActiveRecord::Migration[7.2]
  def change
    add_reference :workouts, :category, foreign_key: true
    add_column :workouts, :is_closed, :boolean, default: false
  end
end
