module Platform
  module Admin
    class SessionsController < Devise::SessionsController
      layout "platform_login"

      # POST /plateforme/admin/connexion
      def create
        super do |user|
          unless user.admin?
            sign_out user
            flash[:alert] = "Accès réservé aux administrateurs."
            redirect_to platform_admin_login_path and return
          end
        end
      end

      private

      def after_sign_in_path_for(resource)
        platform_admin_dashboard_path
      end

      def after_sign_out_path_for(_resource)
        platform_admin_login_path
      end
    end
  end
end
