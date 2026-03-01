class QuizQuestion < ApplicationRecord
  belongs_to :module_formation

  validates :enonce, presence: true
  validates :bonne_reponse, presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  scope :ordonnes, -> { order(:ordre, :created_at) }

  def options_list
    Array(options)
  end

  def bonne_option
    options_list[bonne_reponse]
  end
end
