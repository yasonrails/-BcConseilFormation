class CreateCoursSupports < ActiveRecord::Migration[8.1]
  def change
    create_table :cours_supports do |t|
      t.string   :titre,       null: false
      t.text     :description
      t.text     :contenu_texte  # texte extrait du fichier ou saisi manuellement
      t.string   :statut,     default: "brouillon" # brouillon | pret
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
