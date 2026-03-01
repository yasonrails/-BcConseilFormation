module Platform
  class GenerateurController < BaseController
    before_action :set_support, only: [:generer_modules, :generer_quiz]

    # GET /plateforme/generateur
    def index
      @supports = current_user.cours_supports.recents
    end

    # POST /plateforme/supports/:support_id/generer_modules
    def generer_modules
      contenu = @support.extraire_texte
      if contenu.blank?
        return render json: { error: "Le support ne contient pas de texte extractible." },
                      status: :unprocessable_entity
      end

      nb_modules = (params[:nb_modules] || 3).to_i.clamp(1, 8)

      service = LmsGenerateurService.new(contenu: contenu, nb_modules: nb_modules)
      modules_data = service.generer_modules

      saved_modules = modules_data.map.with_index do |mod_data, idx|
        sections_html = Array(mod_data["sections"]).map do |s|
          "<h3>#{CGI.escapeHTML(s['titre'].to_s)}</h3>\n#{s['contenu']}"
        end.join("\n\n")

        module_obj = @support.module_formations.create!(
          titre:         mod_data["titre"].to_s,
          objectifs:     Array(mod_data["objectifs"]),
          duree_estimee: mod_data["duree_estimee"].to_s,
          contenu:       sections_html,
          ordre:         idx,
          user:          current_user
        )
        module_obj
      end

      render json: {
        success: true,
        modules: saved_modules.map { |m|
          {
            id:            m.id,
            titre:         m.titre,
            objectifs:     m.objectifs_list,
            duree_estimee: m.duree_estimee,
            url:           platform_support_module_path(@support, m)
          }
        }
      }
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    # POST /plateforme/supports/:support_id/modules/:module_id/generer_quiz
    def generer_quiz
      @module = @support.module_formations.find(params[:module_id])
      nb_questions = (params[:nb_questions] || 5).to_i.clamp(3, 15)

      service = LmsGenerateurService.new(
        contenu:      @support.contenu_texte.to_s,
        nb_questions: nb_questions
      )
      questions_data = service.generer_quiz(module_contenu: @module.contenu.to_s)

      questions_data.each_with_index do |q, idx|
        @module.quiz_questions.create!(
          enonce:        q["enonce"].to_s,
          options:       Array(q["options"]),
          bonne_reponse: q["bonne_reponse"].to_i,
          explication:   q["explication"].to_s,
          ordre:         idx
        )
      end

      render json: {
        success:   true,
        questions: @module.quiz_questions.ordonnes.map { |q|
          {
            id:            q.id,
            enonce:        q.enonce,
            options:       q.options_list,
            bonne_reponse: q.bonne_reponse,
            explication:   q.explication
          }
        }
      }
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    def set_support
      @support = current_user.cours_supports.find(params[:support_id])
    end
  end
end
