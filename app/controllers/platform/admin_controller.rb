module Platform
  class AdminController < BaseController
    def index
      @stats = {
        apprenants_actifs:    87,
        formations_publiees:  24,
        taux_completion:      "76%",
        satisfaction:         "4.8"
      }
      @apprenants = [
        { initiales: "ML", nom: "Marie Lambert",  formation: "RH Fondamentaux",  progression: 57,  statut: "En cours",  badge: "tb" },
        { initiales: "JD", nom: "Jean Dupont",    formation: "Droit du Travail",  progression: 100, statut: "Certifié",  badge: "tg" },
        { initiales: "AM", nom: "Anne Martin",    formation: "Audit RH",          progression: 35,  statut: "En cours",  badge: "tb" },
        { initiales: "PL", nom: "Paul Leroy",     formation: "Management",        progression: 10,  statut: "Démarré",   badge: "ta" },
      ]
      @sessions = [
        { date: "VEN 28 FÉV — 14:00", titre: "Audit RH — Session live",     formateur: "Sophie Renard",  participants: 8,  couleur_var: "accent-light", border_var: "rgba(28,95,255,.15)", label_color: "accent" },
        { date: "MER 5 MAR — 10:00",  titre: "Droit du Travail — Module 5", formateur: "Pierre Laurent", participants: 12, couleur_var: "green-bg",     border_var: "rgba(15,146,84,.15)", label_color: "green"  },
      ]
    end
  end
end
