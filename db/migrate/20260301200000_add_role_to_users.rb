class AddRoleToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :role, :string, default: "eleve", null: false
    add_column :users, :prenom, :string
    add_column :users, :nom, :string
    add_index  :users, :role
  end
end
