class QuizQuestion < ApplicationRecord
  include ListAttribute

  belongs_to :module_formation

  validates :enonce, presence: true
  validates :bonne_reponse, presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  TYPES   = %w[qcm vrai_faux scenario].freeze
  NIVEAUX = %w[decouverte comprehension application].freeze

  scope :ordonnes, -> { order(:ordre, :created_at) }

  list_attribute :options

  def bonne_option
    options_list[bonne_reponse]
  end

  def icone_niveau
    { "decouverte" => "🌱", "comprehension" => "💡", "application" => "🎯" }.fetch(niveau.to_s, "❓")
  end

  def icone_type
    { "qcm" => "🔘", "vrai_faux" => "⚖️", "scenario" => "🎭" }.fetch(type_question.to_s, "🔘")
  end
end
