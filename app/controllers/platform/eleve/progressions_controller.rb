module Platform
  module Eleve
    class ProgressionsController < BaseController
      def create
        module_formation = ModuleFormation.publies.find(params[:id])

        unless current_user.inscriptions.exists?(cours_support: module_formation.cours_support)
          return render json: { error: "Non inscrit." }, status: :forbidden
        end

        progression = current_user.progressions.find_or_initialize_by(module_formation: module_formation)
        score = params[:score].to_i

        progression.terminer!(score: score)

        render json: {
          success: true,
          message: score >= 70 ? "Félicitations ! Module validé 🎉" : "Module terminé. Réessayez pour améliorer votre score.",
          score: score
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Module introuvable." }, status: :not_found
      end
    end
  end
end
