module Platform
  module Eleve
    class CatalogueController < BaseController
      def index
        @formations = CoursSupport.publies
                                  .includes(:module_formations, :inscriptions)
                                  .order(updated_at: :desc)
        @mes_ids = current_user.inscriptions.pluck(:cours_support_id)
      end
    end
  end
end
