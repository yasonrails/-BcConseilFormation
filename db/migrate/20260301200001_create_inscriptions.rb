class CreateInscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :inscriptions do |t|
      t.references :user,          null: false, foreign_key: true
      t.references :cours_support, null: false, foreign_key: true
      t.datetime   :inscrit_le,    default: -> { "CURRENT_TIMESTAMP" }
      t.timestamps
    end
    add_index :inscriptions, [:user_id, :cours_support_id], unique: true
  end
end
