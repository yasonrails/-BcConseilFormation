module Platform
  module Eleve
    class CertificatsController < BaseController
      def index
        @certificats = current_user.certificats
                                   .includes(:cours_support)
                                   .recents
      end

      def create
        formation = CoursSupport.publies.find(params[:cours_support_id])

        # Vérifier inscription et complétion
        unless current_user.inscriptions.exists?(cours_support: formation)
          return redirect_to platform_mes_formations_path, alert: "Vous n'êtes pas inscrit à cette formation."
        end

        modules_publies = formation.module_formations.where(statut: "publie")
        termines = current_user.progressions
                               .where(module_formation: modules_publies, termine: true)
                               .count

        if termines < modules_publies.count
          return redirect_to platform_mes_formations_path,
                             alert: "Terminez tous les modules avant de demander votre certificat."
        end

        certificat = current_user.certificats.find_or_initialize_by(cours_support: formation)

        if certificat.new_record?
          certificat.save!
          redirect_to platform_certificats_path,
                      notice: "Demande de certificat envoyée ! Votre certificat sera validé sous 48h."
        else
          redirect_to platform_certificats_path,
                      notice: "Demande déjà enregistrée (statut : #{certificat.statut})."
        end
      rescue ActiveRecord::RecordNotFound
        redirect_to platform_mes_formations_path, alert: "Formation introuvable."
      end

      def show
        @certificat = current_user.certificats.find(params[:id])
      end
    end
  end
end
