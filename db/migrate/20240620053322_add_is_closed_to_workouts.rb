class AddIsClosedToWorkouts < ActiveRecord::Migration[7.2]
  def change
    add_column :workouts, :isclosed, :boolean, default: false
  end
end
