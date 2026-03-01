class Inscription < ApplicationRecord
  belongs_to :user
  belongs_to :cours_support

  validates :user_id,          presence: true
  validates :cours_support_id, presence: true
  validates :user_id, uniqueness: { scope: :cours_support_id, message: "déjà inscrit" }

  scope :recentes, -> { order(created_at: :desc) }

  def progression_percent(user)
    total = cours_support.module_formations.publie.count
    return 0 if total.zero?
    termine = user.progressions.where(module_formation: cours_support.module_formations, termine: true).count
    (termine * 100.0 / total).round
  end
end
