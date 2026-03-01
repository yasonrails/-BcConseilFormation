class Certificat < ApplicationRecord
  belongs_to :user
  belongs_to :cours_support
  belongs_to :approuve_par, class_name: "User", optional: true

  STATUTS = %w[en_attente approuve refuse].freeze

  validates :statut, inclusion: { in: STATUTS }
  validates :numero, presence: true, uniqueness: true
  validates :user_id, uniqueness: { scope: :cours_support_id, message: "certificat déjà émis pour cette formation" }

  before_validation :generer_numero, on: :create

  scope :en_attente, -> { where(statut: "en_attente") }
  scope :approuves,  -> { where(statut: "approuve") }
  scope :recents,    -> { order(created_at: :desc) }

  def en_attente? = statut == "en_attente"
  def approuve?   = statut == "approuve"
  def refuse?     = statut == "refuse"

  def approuver!(par:, message: nil)
    update!(
      statut:       "approuve",
      approuve_par: par,
      approuve_le:  Time.current,
      message_admin: message
    )
  end

  def refuser!(par:, message: nil)
    update!(
      statut:       "refuse",
      approuve_par: par,
      message_admin: message
    )
  end

  private

  def generer_numero
    self.numero ||= "CERT-#{Time.current.strftime('%Y%m')}-#{SecureRandom.hex(4).upcase}"
  end
end
