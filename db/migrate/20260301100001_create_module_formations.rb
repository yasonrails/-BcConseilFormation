class CreateModuleFormations < ActiveRecord::Migration[8.1]
  def change
    create_table :module_formations do |t|
      t.string     :titre,          null: false
      t.jsonb      :objectifs,      default: []   # ["Objectif 1", ...]
      t.text       :contenu                        # HTML généré
      t.string     :duree_estimee                  # "2h30"
      t.string     :statut,         default: "brouillon" # brouillon | publie
      t.integer    :ordre,          default: 0
      t.references :cours_support,  null: false, foreign_key: true
      t.references :user,           null: false, foreign_key: true

      t.timestamps
    end
  end
end
