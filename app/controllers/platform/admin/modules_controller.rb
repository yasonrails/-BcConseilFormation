module Platform
  module Admin
    class ModulesController < BaseController
      before_action :set_support
      before_action :set_module

      def show
        @quiz = @module.quiz_questions.order(:ordre)
        @progressions = Progression.where(module_formation: @module).includes(:user)
      end

      def edit; end

      def update
        if @module.update(module_params)
          redirect_to platform_admin_support_module_path(@support, @module), notice: "Module mis à jour."
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @module.destroy
        redirect_to platform_admin_support_path(@support), notice: "Module supprimé."
      end

      def publier
        @module.update!(statut: "publie")
        redirect_to platform_admin_support_module_path(@support, @module), notice: "Module publié."
      end

      private

      def set_support
        @support = CoursSupport.find(params[:support_id])
      end

      def set_module
        @module = @support.module_formations.find(params[:id])
      end

      def module_params
        params.require(:module_formation).permit(:titre, :contenu, :duree_estimee, :statut, :ordre, objectifs: [])
      end
    end
  end
end
