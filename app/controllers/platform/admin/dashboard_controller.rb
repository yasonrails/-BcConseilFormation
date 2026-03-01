module Platform
  module Admin
    class DashboardController < BaseController
      def index
        @total_supports   = CoursSupport.count
        @total_eleves     = User.where(role: "eleve").count
        @total_modules    = ModuleFormation.count
        @supports_publies = CoursSupport.where(statut: "publie").count
        @supports_recents = CoursSupport.includes(:user).order(created_at: :desc).limit(5)
        @eleves_recents   = User.where(role: "eleve").order(created_at: :desc).limit(5)
        @inscriptions_recentes = Inscription.includes(:user, :cours_support).order(created_at: :desc).limit(8)
      end
    end
  end
end
