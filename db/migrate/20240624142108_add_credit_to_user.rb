class AddCreditToUser < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :credit, :decimal, default: 0
    add_column :users, :session_token, :string
  end
end
