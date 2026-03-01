module Platform
  class DashboardController < BaseController
    def index
      # formations en cours (mocked — à remplacer par les données réelles)
      @user_name   = current_user&.email&.split("@")&.first&.humanize || "Apprenant"
      @formations_en_cours = 3
      @progression         = 68
      @temps_formation      = "14h"
      @certificats          = 2
    end
  end
end
