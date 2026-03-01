module Platform
  class ModulesController < BaseController
    before_action :set_support
    before_action :set_module, only: [:show, :edit, :update, :destroy]

    def show; end

    def edit; end

    def update
      if @module.update(module_params)
        redirect_to platform_support_module_path(@support, @module), notice: "Module mis à jour."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @module.destroy
      redirect_to platform_support_path(@support), notice: "Module supprimé."
    end

    private

    def set_support
      @support = current_user.cours_supports.find(params[:support_id])
    end

    def set_module
      @module = @support.module_formations.find(params[:id])
    end

    def module_params
      params.require(:module_formation).permit(:titre, :duree_estimee, :contenu, :statut, :ordre,
                                               objectifs: [])
    end
  end
end
