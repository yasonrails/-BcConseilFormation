module Platform
  module Admin
    class SupportsController < BaseController
      before_action :set_support, only: [:show, :edit, :update, :destroy, :publier, :depublier]

      def index
        @supports = CoursSupport.includes(:user, :module_formations, :inscriptions)
                                .order(created_at: :desc)
      end

      def show
        @modules   = @support.module_formations.order(:ordre)
        @inscriptions = @support.inscriptions.includes(:user).order(created_at: :desc)
      end

      def new
        @support = CoursSupport.new
      end

      def create
        @support = CoursSupport.new(support_params)
        @support.user = current_user
        if @support.save
          redirect_to platform_admin_support_path(@support), notice: "Support créé avec succès."
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit; end

      def update
        if @support.update(support_params)
          redirect_to platform_admin_support_path(@support), notice: "Support mis à jour."
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @support.destroy
        redirect_to platform_admin_supports_path, notice: "Support supprimé."
      end

      def publier
        @support.update!(statut: "publie")
        redirect_to platform_admin_support_path(@support), notice: "Support publié — visible par les élèves."
      end

      def depublier
        @support.update!(statut: "brouillon")
        redirect_to platform_admin_support_path(@support), notice: "Support dépublié."
      end

      private

      def set_support
        @support = CoursSupport.find(params[:id])
      end

      def support_params
        params.require(:cours_support).permit(:titre, :description, :contenu_texte, :statut, :fichier)
      end
    end
  end
end
