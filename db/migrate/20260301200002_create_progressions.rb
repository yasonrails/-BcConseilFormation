class CreateProgressions < ActiveRecord::Migration[8.1]
  def change
    create_table :progressions do |t|
      t.references :user,             null: false, foreign_key: true
      t.references :module_formation, null: false, foreign_key: true
      t.boolean    :termine,          default: false, null: false
      t.integer    :score                          # score quiz 0-100
      t.datetime   :termine_le
      t.timestamps
    end
    add_index :progressions, [:user_id, :module_formation_id], unique: true
  end
end
