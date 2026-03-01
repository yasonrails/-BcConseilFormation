class ModuleFormation < ApplicationRecord
  include Statutable
  include ListAttribute

  belongs_to :cours_support
  belongs_to :user
  has_many :quiz_questions, -> { order(:ordre) }, dependent: :destroy

  validates :titre, presence: true

  STATUTS = %w[brouillon publie].freeze

  scope :ordonnes, -> { order(:ordre, :created_at) }
  scope :publies,  -> { where(statut: "publie") }

  list_attribute :objectifs

  def publie?
    en_statut?("publie")
  end
end
