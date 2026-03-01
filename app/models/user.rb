class User < ApplicationRecord
  ROLES = %w[admin eleve].freeze

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :cours_supports,    dependent: :destroy
  has_many :module_formations, dependent: :destroy
  has_many :inscriptions,      dependent: :destroy
  has_many :formations_inscrites, through: :inscriptions, source: :cours_support
  has_many :progressions,      dependent: :destroy

  validates :role, inclusion: { in: ROLES }

  def admin?  = role == "admin"
  def eleve?  = role == "eleve"

  def nom_complet
    [prenom, nom].compact.join(" ").presence || email
  end
end
