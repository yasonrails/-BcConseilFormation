module Platform
  module Admin
    class GenerateurController < BaseController
      before_action :set_support, only: [:generer_modules, :generer_slides, :generer_quiz, :ia_statut]

      # GET /plateforme/admin/generateur
      def index
        @supports = CoursSupport.recents.includes(:module_formations)
      end

      # POST /plateforme/admin/supports/:support_id/generer_modules
      # Enqueue le job → répond 202 immédiatement (pas de blocage HTTP).
      def generer_modules
        contenu = @support.extraire_texte
        return api_error("Le support ne contient pas de texte extractible.") if contenu.blank?

        nb_modules = (params[:nb_modules] || 3).to_i.clamp(1, 8)
        ia_marquer(@support, "modules", "en_attente")
        LmsGenerateurJob.perform_later(
          support_id: @support.id,
          nb_modules:  nb_modules,
          user_id:     current_user.id
        )

        render json: { queued: true, statut: "en_attente" }, status: :accepted
      rescue => e
        api_error(e.message)
      end

      # POST /plateforme/admin/supports/:support_id/generer_slides
      def generer_slides
        contenu = @support.extraire_texte
        return api_error("Le support ne contient pas de texte extractible.") if contenu.blank?

        nb_slides = (params[:nb_slides] || 8).to_i.clamp(4, 20)
        ia_marquer(@support, "slides", "en_attente")
        LmsSlidesJob.perform_later(support_id: @support.id, nb_slides: nb_slides)

        render json: { queued: true, statut: "en_attente" }, status: :accepted
      rescue => e
        api_error(e.message)
      end

      # POST /plateforme/admin/supports/:support_id/modules/:id/generer_quiz
      def generer_quiz
        mod          = @support.module_formations.find(params[:id])
        nb_questions = (params[:nb_questions] || 7).to_i.clamp(3, 10)

        ia_marquer_quiz(@support, mod.id, "en_attente")
        LmsQuizJob.perform_later(
          support_id:   @support.id,
          module_id:    mod.id,
          nb_questions: nb_questions
        )

        render json: { queued: true, module_id: mod.id, statut: "en_attente" }, status: :accepted
      rescue => e
        api_error(e.message)
      end

      # GET /plateforme/admin/supports/:support_id/ia_statut
      # Polling endpoint – appelé toutes les 2s par le JS jusqu'à statut ok/erreur.
      def ia_statut
        ia = @support.programme_json.fetch("ia", {})

        render json: {
          modules: ia_bloc(ia, "modules"),
          slides:  ia_bloc(ia, "slides"),
          quiz:    ia.fetch("quiz", {}).transform_values { |v|
                     { statut: v["statut"], erreur: v["erreur"], count: v["count"] }
                   }
        }
      end

      # GET /plateforme/admin/supports/:support_id/slides
      def slides_preview
        @support = CoursSupport.find(params[:support_id])
        @slides  = Array(@support.programme_json&.dig("slides"))
        render :slides_preview
      end

      private

      def set_support
        @support = CoursSupport.find(params[:support_id])
      end

      # Écrit le statut initial dans programme_json avant d'enqueuer
      def ia_marquer(support, cle, statut)
        pj = support.programme_json.deep_dup
        pj["ia"]      ||= {}
        pj["ia"][cle] = { "statut" => statut, "maj_le" => Time.current.iso8601, "erreur" => nil }
        support.update_columns(programme_json: pj)
      end

      def ia_marquer_quiz(support, module_id, statut)
        pj = support.programme_json.deep_dup
        pj["ia"]         ||= {}
        pj["ia"]["quiz"] ||= {}
        pj["ia"]["quiz"][module_id.to_s] = { "statut" => statut, "maj_le" => Time.current.iso8601, "erreur" => nil }
        support.update_columns(programme_json: pj)
      end

      def ia_bloc(ia, cle)
        bloc = ia.fetch(cle, {})
        { statut: bloc.fetch("statut", "idle"), erreur: bloc["erreur"], count: bloc["count"] }
      end
    end

  end
end
