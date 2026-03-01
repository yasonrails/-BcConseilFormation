module Platform
  module Admin
    class CertificatsController < BaseController
      before_action :set_certificat, only: [:show, :approuver, :refuser]

      def index
        @certificats = Certificat.includes(:user, :cours_support, :approuve_par)
                                 .recents
        @certificats = @certificats.en_attente if params[:statut] == "en_attente"
        @certificats = @certificats.approuves  if params[:statut] == "approuve"
      end

      def show; end

      def approuver
        @certificat.approuver!(par: current_user, message: params[:message_admin])
        redirect_to platform_admin_certificats_path, notice: "Certificat approuvé et délivré."
      rescue => e
        redirect_to platform_admin_certificat_path(@certificat), alert: e.message
      end

      def refuser
        @certificat.refuser!(par: current_user, message: params[:message_admin])
        redirect_to platform_admin_certificats_path, notice: "Certificat refusé."
      rescue => e
        redirect_to platform_admin_certificat_path(@certificat), alert: e.message
      end

      private

      def set_certificat
        @certificat = Certificat.find(params[:id])
      end
    end
  end
end
