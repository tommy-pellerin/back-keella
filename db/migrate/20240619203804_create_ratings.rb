class CreateRatings < ActiveRecord::Migration[7.2]
  def change
    create_table :ratings do |t|
      t.integer :rating
      t.text :comment
      t.references :workout, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true # l'utilisateur qui note
      t.references :rated_user, null: false, foreign_key: { to_table: :users } # l'utilisateur noté
      t.boolean :is_workout_rating, default: false # true si c'est une note pour le workout, false si c'est une note pour l'utilisateur

      t.timestamps
    end

    add_index :ratings, [ :user_id, :workout_id, :rated_user_id ], unique: true
  end
end
