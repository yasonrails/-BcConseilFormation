class CreateQuizQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :quiz_questions do |t|
      t.text     :enonce,         null: false
      t.jsonb    :options,        default: []   # ["Option A", "Option B", ...]
      t.integer  :bonne_reponse,  null: false   # index dans `options`
      t.text     :explication                   # feedback après réponse
      t.integer  :ordre,          default: 0
      t.references :module_formation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
