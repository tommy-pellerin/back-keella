class AddUserNameToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :username, :string
    add_column :users, :isAdmin, :boolean, default: false
  end
end
