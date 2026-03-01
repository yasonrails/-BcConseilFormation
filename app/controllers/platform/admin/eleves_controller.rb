module Platform
  module Admin
    class ElevesController < BaseController
      def index
        @eleves = User.where(role: "eleve")
                      .includes(:inscriptions, :progressions)
                      .order(created_at: :desc)
      end

      def show
        @eleve = User.where(role: "eleve").find(params[:id])
        @inscriptions = @eleve.inscriptions.includes(:cours_support).order(created_at: :desc)
        @progressions = @eleve.progressions.includes(module_formation: :cours_support).terminees
      end
    end
  end
end
