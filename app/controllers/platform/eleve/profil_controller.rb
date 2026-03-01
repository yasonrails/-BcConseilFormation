module Platform
  module Eleve
    class ProfilController < BaseController
      def index
        @inscriptions   = current_user.inscriptions.includes(:cours_support)
        @progressions   = current_user.progressions.terminees.includes(module_formation: :cours_support)
        @total_modules  = @progressions.count
        @score_moyen    = @progressions.where.not(score: nil).average(:score)&.round
      end
    end
  end
end
