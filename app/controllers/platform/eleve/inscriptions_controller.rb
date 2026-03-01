module Platform
  module Eleve
    class InscriptionsController < BaseController
      def create
        @formation = CoursSupport.publies.find(params[:id])

        inscription = current_user.inscriptions.find_or_initialize_by(cours_support: @formation)

        if inscription.new_record?
          inscription.save!
          redirect_to platform_mes_formations_path, notice: "Inscription confirmée ! Bonne formation 🎓"
        else
          redirect_to platform_catalogue_path, notice: "Vous êtes déjà inscrit à cette formation."
        end
      rescue ActiveRecord::RecordNotFound
        redirect_to platform_catalogue_path, alert: "Formation introuvable."
      end
    end
  end
end
