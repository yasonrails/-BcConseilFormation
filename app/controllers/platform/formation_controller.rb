module Platform
  class FormationController < BaseController
    def index
      @formation_titre = "RH Fondamentaux & Recrutement"
      @progression     = 57
      @modules = [
        { numero: 1, titre: "Fondamentaux RH",          sous: "Rôle de la fonction RH, enjeux stratégiques", duree: "3h",  statut: :done },
        { numero: 2, titre: "Recrutement & Sélection",  sous: "Méthodes, outils, biais cognitifs",           duree: "4h",  statut: :done },
        { numero: 3, titre: "Intégration & Onboarding", sous: "Parcours d'intégration, indicateurs clés",    duree: "3h",  statut: :done },
        { numero: 4, titre: "Gestion des talents",      sous: "En cours — 45% complété",                     duree: "4h",  statut: :current },
        { numero: 5, titre: "Gestion des performances", sous: "Entretiens, évaluation, feedback continu",    duree: "3h",  statut: :locked },
        { numero: 6, titre: "Droit & Conformité RH",   sous: "Obligations légales, RGPD",                   duree: "2h",  statut: :locked },
        { numero: 7, titre: "Cas pratiques & Certification", sous: "Quiz final, certificat",                 duree: "2h",  statut: :locked },
      ]
    end
  end
end
