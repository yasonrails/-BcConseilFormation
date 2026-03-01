class CreateCertificats < ActiveRecord::Migration[8.1]
  def change
    create_table :certificats do |t|
      t.references :user,          null: false, foreign_key: true
      t.references :cours_support, null: false, foreign_key: true
      t.string     :statut,        null: false, default: "en_attente"
      t.string     :numero,        null: false  # ex: CERT-2026-00001
      t.references :approuve_par,  null: true,  foreign_key: { to_table: :users }
      t.datetime   :approuve_le
      t.text       :message_admin  # commentaire optionnel de l'admin

      t.timestamps
    end

    add_index :certificats, [:user_id, :cours_support_id], unique: true
    add_index :certificats, :numero, unique: true
    add_index :certificats, :statut
  end
end
