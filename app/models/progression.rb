class Progression < ApplicationRecord
  belongs_to :user
  belongs_to :module_formation

  validates :user_id,             presence: true
  validates :module_formation_id, presence: true
  validates :user_id, uniqueness: { scope: :module_formation_id }

  scope :terminees, -> { where(termine: true) }
  scope :en_cours,  -> { where(termine: false) }

  def terminer!(score: nil)
    update!(termine: true, score: score, termine_le: Time.current)
  end
end
