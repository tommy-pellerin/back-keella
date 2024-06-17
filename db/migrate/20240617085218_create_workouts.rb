class CreateWorkouts < ActiveRecord::Migration[7.2]
  def change
    create_table :workouts do |t|
      t.string :title
      t.text :description
      t.datetime :start_date
      t.float :duration
      t.string :city
      t.string :zip_code
      t.decimal :price
      t.references :host, foreign_key: { to_table: :users }
      t.integer :max_participants

      t.timestamps
    end
  end
end
