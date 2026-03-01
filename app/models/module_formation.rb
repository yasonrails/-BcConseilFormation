class ModuleFormation < ApplicationRecord
  belongs_to :cours_support
  belongs_to :user
  has_many :quiz_questions, -> { order(:ordre) }, dependent: :destroy

  validates :titre, presence: true

  STATUTS = %w[brouillon publie].freeze

  scope :ordonnes,  -> { order(:ordre, :created_at) }
  scope :publies,   -> { where(statut: "publie") }

  def publie?
    statut == "publie"
  end

  def objectifs_list
    Array(objectifs)
  end
end
