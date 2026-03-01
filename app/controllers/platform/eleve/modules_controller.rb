module Platform
  module Eleve
    class ModulesController < BaseController
      before_action :set_module
      before_action :check_inscription

      def show
        @quiz        = @module.quiz_questions.order(:ordre)
        @progression = current_user.progressions.find_or_initialize_by(module_formation: @module)
        @autres_modules = @module.cours_support.module_formations.publies.order(:ordre)
        # Précharger les progressions pour la navigation latérale (pas de N+1)
        @progressions_par_module = current_user.progressions
                                               .where(module_formation: @autres_modules)
                                               .index_by(&:module_formation_id)
      end

      private

      def set_module
        @module  = ModuleFormation.publies.includes(:cours_support, :quiz_questions).find(params[:id])
        @support = @module.cours_support
      end

      def check_inscription
        unless current_user.inscriptions.exists?(cours_support: @support)
          redirect_to platform_catalogue_path, alert: "Inscrivez-vous d'abord à cette formation."
        end
      end
    end
  end
end
