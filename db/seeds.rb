# ============================================================
# SEEDS — BC Conseil Formation LMS
# ============================================================
# Réinitialise proprement la base et crée les comptes de base.
# Lancez avec : bin/rails db:seed   (ou db:schema:load puis db:seed)
# ============================================================

puts "🌱 Nettoyage de la base..."
QuizQuestion.delete_all
ModuleFormation.delete_all
Inscription.delete_all
Progression.delete_all
CoursSupport.delete_all
User.delete_all

puts "👤 Création de l'administrateur..."
admin = User.create!(
  email:                 "admin@bcFormation.fr",
  password:              "AdminBc2026!",
  password_confirmation: "AdminBc2026!",
  role:                  "admin",
  prenom:                "Admin",
  nom:                   "BC Formation"
)
puts "   ✓ admin@bcFormation.fr / AdminBc2026!"

puts "👤 Création d'un compte élève de test..."
eleve = User.create!(
  email:                 "eleve@test.fr",
  password:              "Eleve2026!",
  password_confirmation: "Eleve2026!",
  role:                  "eleve",
  prenom:                "Jean",
  nom:                   "Dupont"
)
puts "   ✓ eleve@test.fr / Eleve2026!"

puts "📚 Création d'un support de cours démo..."
support = CoursSupport.create!(
  user:          admin,
  titre:         "Introduction au Management",
  description:   "Les fondamentaux du management d'équipe pour les nouveaux managers.",
  contenu_texte: <<~TEXTE,
    Le management est l'ensemble des techniques d'organisation visant à conduire l'action d'un groupe.

    Rôle du manager :
    - Fixer des objectifs clairs et mesurables (méthode SMART)
    - Motiver et fédérer l'équipe autour d'un projet commun
    - Déléguer efficacement en fonction des compétences de chacun
    - Évaluer les performances et accompagner les collaborateurs

    Les styles de management :
    1. Directif : le manager fixe les objectifs et les méthodes sans concertation
    2. Persuasif : le manager explique et convainc avant d'agir
    3. Participatif : le manager associe l'équipe à la prise de décision
    4. Délégatif : le manager confie la responsabilité à des collaborateurs autonomes

    La communication managériale :
    Une communication efficace repose sur l'écoute active, la reformulation et le feedback régulier.
    Le manager doit savoir adapter son discours à son interlocuteur.

    Gestion des conflits :
    Les conflits sont inévitables en équipe. Le manager doit les identifier tôt,
    comprendre les causes profondes et faciliter la résolution par le dialogue.
  TEXTE
  statut: "publie"
)
puts "   ✓ Support '#{support.titre}' créé et publié"

puts "🔗 Inscription de l'élève démo au support..."
Inscription.create!(user: eleve, cours_support: support)
puts "   ✓ Inscrit"

puts "\n✅ Seeds terminés !"
puts "══════════════════════════════════════════"
puts "ADMIN  : admin@bcFormation.fr / AdminBc2026!"
puts "ÉLÈVE  : eleve@test.fr        / Eleve2026!"
puts "══════════════════════════════════════════"
puts "Rendez-vous sur /plateforme pour commencer."

