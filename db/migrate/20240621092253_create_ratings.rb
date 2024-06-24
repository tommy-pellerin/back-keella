class CreateRatings < ActiveRecord::Migration[7.2]
  def change
    create_table :ratings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :rateable, polymorphic: true, null: false
      t.references :workout, null: false, foreign_key: true
      t.integer :rating
      t.text :comment

      t.timestamps
    end
    add_index :ratings, [ :rateable_id, :rateable_type ]
    add_index :ratings, [ :user_id, :rateable_type, :rateable_id, :workout_id ], unique: true, name: "index_ratings_on_user_and_rateable"
  end
end
