module Platform
  class ProfilController < BaseController
    def index
      @user_name  = current_user&.email&.split("@")&.first&.humanize || "Apprenant"
      @user_initiales = @user_name.split.map(&:first).first(2).join.upcase
      @user_role  = "Responsable Ressources Humaines"
      @certificats = [
        { titre: "RH Fondamentaux v1",           date: "18 fév. 2026", obtenu: true  },
        { titre: "Droit du Travail — Niveau 1",  date: "5 jan. 2026",  obtenu: true  },
        { titre: "Conduite d'Audit RH",          date: "En cours — 20%", obtenu: false },
      ]
      @competences = [
        { nom: "Gestion RH",          niveau: 85, classe: "" },
        { nom: "Droit du Travail",    niveau: 72, classe: "g" },
        { nom: "Recrutement",         niveau: 90, classe: "" },
        { nom: "Audit & Conformité",  niveau: 25, classe: "", couleur: "#f59e0b" },
      ]
    end
  end
end
