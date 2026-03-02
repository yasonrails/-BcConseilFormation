# LmsSlidesService
# Génère une présentation slide-by-slide depuis un support (PDF / PPTX / texte).
# Le provider IA est sélectionné via AiProvider::Registry (ENV AI_PROVIDER ou credentials).
# Indépendant du générateur de modules et du quiz.
#
class LmsSlidesService
  def initialize(contenu:, nb_slides: 8, langue: "fr")
    @contenu   = contenu.to_s.strip.truncate(14_000)
    @nb_slides = nb_slides.to_i.clamp(4, 20)
    @langue    = langue
    @ai        = AiProvider::Registry.build
  end

  def generer_slides
    prompt = <<~PROMPT
      Tu es un expert en conception de présentations pédagogiques.
      À partir du contenu ci-dessous (extrait de PDF ou PowerPoint), génère #{@nb_slides} slides de présentation.

      Retourne UNIQUEMENT un tableau JSON :
      [
        {
          "ordre": 1,
          "type": "titre",
          "titre": "Titre principal de la formation",
          "sous_titre": "Sous-titre ou accroche",
          "notes": "Notes du formateur (optionnel)"
        },
        {
          "ordre": 2,
          "type": "objectifs",
          "titre": "Objectifs de la formation",
          "items": ["À l'issue de cette formation, vous serez capable de…", "Objectif 2", "Objectif 3"],
          "notes": ""
        },
        {
          "ordre": 3,
          "type": "contenu",
          "titre": "Titre de la slide",
          "items": ["Point clé 1", "Point clé 2", "Point clé 3"],
          "details": "Paragraphe de contexte ou définition (2-3 phrases max)",
          "notes": "Note formateur"
        },
        {
          "ordre": 4,
          "type": "definition",
          "titre": "Concept clé",
          "definition": "Définition concise et claire",
          "exemple": "Exemple concret",
          "notes": ""
        },
        {
          "ordre": 5,
          "type": "cas_pratique",
          "titre": "Mise en situation",
          "scenario": "Description d'un cas pratique réaliste",
          "questions": ["Question de réflexion 1", "Question 2"],
          "notes": ""
        },
        {
          "ordre": 99,
          "type": "conclusion",
          "titre": "Points clés à retenir",
          "items": ["Point 1", "Point 2", "Point 3"],
          "cta": "Action à mettre en place dès demain",
          "notes": ""
        }
      ]

      Types disponibles : "titre" | "objectifs" | "contenu" | "definition" | "cas_pratique" | "chiffre_cle" | "citation" | "conclusion"
      Pour "chiffre_cle" : ajouter "chiffre" (ex: "73%") et "legende".
      Pour "citation" : ajouter "citation" et "auteur".

      Règles :
      - Langue : #{@langue}
      - Première slide : type "titre"
      - Deuxième slide : type "objectifs"
      - Dernière slide : type "conclusion"
      - Varier les types pour éviter la monotonie
      - Items courts (max 10 mots chacun)
      - Cas pratiques ancrés dans la réalité professionnelle
      - JSON seul, pas d'autre texte

      CONTENU SOURCE :
      #{@contenu}
    PROMPT
    @ai.chat_json(prompt)
  rescue AiProvider::Base::ProviderError => e
    Rails.logger.error "LmsSlidesService: #{e.message}"
    raise
  end
end
