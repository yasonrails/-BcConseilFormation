module Platform
  class MessagerieController < BaseController
    def index
      @conversations = [
        { initiales: "SR", nom: "Sophie Renard",  dernier_msg: "Oui tout à fait, n'hésitez pas à me…", heure: "10h12", actif: true,  non_lu: true  },
        { initiales: "BC", nom: "BC Formation",   dernier_msg: "Votre certificat est disponible…",      heure: "Hier",  actif: false, non_lu: false },
        { initiales: "PL", nom: "Pierre Laurent", dernier_msg: "La session de vendredi est confirmée",  heure: "18 fév",actif: false, non_lu: false },
      ]
      @messages_actifs = [
        { role: :them, auteur: "Sophie",   texte: "Bonjour Marie, comment avancez-vous sur le module 4 ? Avez-vous des questions sur la partie «&nbsp;matrice des compétences&nbsp;» ?", heure: "Sophie · 09h45" },
        { role: :me,   auteur: "Moi",      texte: "Bonjour Sophie ! Oui, je progresse bien. J'ai une question sur la méthode de pondération des compétences critiques.",                heure: "Moi · 10h02" },
        { role: :them, auteur: "Sophie",   texte: "Excellente question. Pour votre secteur, je recommande : compétences relationnelles 40%, techniques 35%, managériales 25%.",         heure: "Sophie · 10h12" },
        { role: :them, auteur: "Sophie",   texte: "N'hésitez pas à me partager votre matrice pour un retour personnalisé.",                                                              heure: "Sophie · 10h13" },
      ]
    end
  end
end
