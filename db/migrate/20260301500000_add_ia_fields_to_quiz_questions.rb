class AddIaFieldsToQuizQuestions < ActiveRecord::Migration[8.1]
  def change
    add_column :quiz_questions, :type_question, :string, default: "qcm"
    add_column :quiz_questions, :niveau,        :string, default: "comprehension"
    add_column :quiz_questions, :pourquoi,      :text
    add_column :quiz_questions, :point_cle,     :string
  end
end
