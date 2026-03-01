module Platform
  module Eleve
    class MesFormationsController < BaseController
      def index
        @inscriptions = current_user.inscriptions
                                    .includes(cours_support: { module_formations: {} })
                                    .order(created_at: :desc)

        # Précharger toutes les progressions en une seule requête
        module_ids = @inscriptions.flat_map { |i| i.cours_support.module_formations.map(&:id) }
        @progressions = current_user.progressions
                                    .where(module_formation_id: module_ids)
                                    .index_by(&:module_formation_id)
      end
    end
  end
end
