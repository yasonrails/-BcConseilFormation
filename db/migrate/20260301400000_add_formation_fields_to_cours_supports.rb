class AddFormationFieldsToCoursSupports < ActiveRecord::Migration[8.1]
  def change
    add_column :cours_supports, :ref_formation,         :string
    add_column :cours_supports, :duree_jours,           :integer
    add_column :cours_supports, :duree_heures,          :integer
    add_column :cours_supports, :prix_inter,            :decimal, precision: 8, scale: 2
    add_column :cours_supports, :max_participants,      :integer
    add_column :cours_supports, :acompte_pct,           :integer, default: 20
    add_column :cours_supports, :modalite,              :string,  default: "presentiel"
    add_column :cours_supports, :categorie,             :string
    add_column :cours_supports, :public_cible,          :text
    add_column :cours_supports, :prerequis,             :text
    add_column :cours_supports, :financement_info,      :text
    add_column :cours_supports, :programme_json,        :jsonb,   default: {}
    add_column :cours_supports, :sessions_disponibles,  :jsonb,   default: []

    add_index :cours_supports, :ref_formation, unique: true, where: "ref_formation IS NOT NULL"
    add_index :cours_supports, :categorie
  end
end
