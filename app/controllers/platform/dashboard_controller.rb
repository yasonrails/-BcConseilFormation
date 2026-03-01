module Platform
  class DashboardController < BaseController
    def index
      if current_user.admin?
        redirect_to platform_admin_dashboard_path
      else
        redirect_to platform_catalogue_path
      end
    end
  end
end
