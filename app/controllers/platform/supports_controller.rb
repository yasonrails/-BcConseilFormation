module Platform
  class SupportsController < BaseController
    before_action :set_support, only: [:show, :edit, :update, :destroy]

    def index
      @supports = current_user.cours_supports.recents
    end

    def show
      @modules = @support.module_formations.ordonnes
    end

    def new
      @support = CoursSupport.new
    end

    def create
      @support = current_user.cours_supports.build(support_params)

      # Extraction automatique du texte si un fichier est uploadé
      if params[:cours_support][:fichier].present? && @support.contenu_texte.blank?
        @support.save # pour attacher le fichier via Active Storage
        @support.contenu_texte = @support.extraire_texte
      end

      if @support.save
        redirect_to platform_support_path(@support),
                    notice: "Support « #{@support.titre} » créé avec succès."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @support.update(support_params)
        redirect_to platform_support_path(@support), notice: "Support mis à jour."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @support.destroy
      redirect_to platform_supports_path, notice: "Support supprimé."
    end

    private

    def set_support
      @support = current_user.cours_supports.find(params[:id])
    end

    def support_params
      params.require(:cours_support).permit(:titre, :description, :contenu_texte, :fichier, :statut)
    end
  end
end
