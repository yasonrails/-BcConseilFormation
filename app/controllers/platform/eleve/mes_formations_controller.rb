module Platform
  module Eleve
    class MesFormationsController < BaseController
      def index
        @inscriptions = current_user.inscriptions
                                    .includes(:cours_support)
                                    .order(created_at: :desc)
      end
    end
  end
end
