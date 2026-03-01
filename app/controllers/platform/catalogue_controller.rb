module Platform
  class CatalogueController < BaseController
    def index
      @formations = [
        { title: "RH Fondamentaux & Recrutement",            category: "RH",         modules: 7,  heures: 21, prix: "1 490",  couleur: "linear-gradient(135deg,#1c5fff,#6366f1)", badge_class: "tb", financement: false },
        { title: "Droit du Travail Appliqué",                category: "Droit",       modules: 5,  heures: 14, prix: "1 290",  couleur: "linear-gradient(135deg,#0f9254,#34d399)", badge_class: "tg", financement: false },
        { title: "Conduite d'Audit RH",                      category: "Audit",       modules: 6,  heures: 18, prix: "1 890",  couleur: "linear-gradient(135deg,#b45309,#f59e0b)", badge_class: "ta", financement: false },
        { title: "Management & Leadership Stratégique",       category: "Management",  modules: 8,  heures: 24, prix: "1 690",  couleur: "linear-gradient(135deg,#7c3aed,#a78bfa)", badge_class: "tb", financement: false },
        { title: "Structurer sa fonction RH — PCRH",         category: "PCRH",        modules: 4,  heures: 12, prix: nil,      couleur: "linear-gradient(135deg,#0e7490,#22d3ee)", badge_class: "tg", financement: true  },
      ]
    end
  end
end
