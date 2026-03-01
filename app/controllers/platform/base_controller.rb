module Platform
  class BaseController < ApplicationController
    layout "platform"
    before_action :authenticate_user!

    # ─── Shared finders ─────────────────────────────────────────────
    def set_support(scope = current_user.cours_supports)
      id = params[:support_id] || params[:id]
      @support = scope.find(id)
    end

    # ─── Error helpers ───────────────────────────────────────────────
    def api_error(message, status: :unprocessable_entity)
      render json: { error: message }, status: status
    end

    private

    def require_admin!
      unless current_user&.admin?
        redirect_to platform_dashboard_path, alert: "Accès réservé aux administrateurs."
      end
    end

    def require_eleve!
      unless current_user&.eleve?
        redirect_to platform_admin_dashboard_path, notice: "Redirection espace admin."
      end
    end
  end
end

