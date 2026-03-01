Rails.application.routes.draw do
  devise_for :users

  # ── Page de connexion dédiée admin ─────────────────
  devise_scope :user do
    get  "/plateforme/admin/connexion",
         to:   "platform/admin/sessions#new",
         as:   "platform_admin_login"
    post "/plateforme/admin/connexion",
         to:   "platform/admin/sessions#create"
    delete "/plateforme/admin/deconnexion",
         to:   "platform/admin/sessions#destroy",
         as:   "platform_admin_logout"
  end

  root to: "pages#home"

  # ────────────────────────────────────────────────
  # PLATEFORME LMS
  # ────────────────────────────────────────────────
  scope "/plateforme", module: "platform", as: "platform" do
    # Dashboard commun (redirige selon rôle)
    get "/" => "dashboard#index", as: "dashboard"

    # ── ADMIN ────────────────────────────────────
    namespace :admin, path: "admin", as: "admin" do
      get  "/"        => "dashboard#index",  as: "dashboard"
      get  "/eleves"  => "eleves#index",     as: "eleves"
      get  "/eleves/:id" => "eleves#show",   as: "eleve"

      # Supports de cours (CRUD complet)
      resources :supports, path: "supports" do
        member do
          patch :publier
          patch :depublier
          post  :generer_modules, controller: "generateur"
          post  :generer_slides,  controller: "generateur"
          get   :slides_preview,  controller: "generateur"
          get   :ia_statut,       controller: "generateur"
        end
        resources :modules, path: "modules", controller: "modules",
                            only: [:show, :edit, :update, :destroy] do
          member do
            patch :publier
            post  :generer_quiz, controller: "generateur"
          end
        end
      end

      # Générateur IA
      get "/generateur" => "generateur#index", as: "generateur"

      # Certificats
      resources :certificats, only: [:index, :show] do
        member do
          patch :approuver
          patch :refuser
        end
      end
    end

    # ── ÉLÈVE ────────────────────────────────────
    get  "/catalogue"     => "eleve/catalogue#index",     as: "catalogue"
    get  "/mes-formations" => "eleve/mes_formations#index", as: "mes_formations"
    post "/inscription/:id" => "eleve/inscriptions#create", as: "inscription"
    get  "/module/:id"    => "eleve/modules#show",        as: "module"
    post "/module/:id/progression" => "eleve/progressions#create", as: "module_progression"
    get  "/profil"        => "eleve/profil#index",        as: "profil"

    # Certificats élève
    resources :certificats, path: "certificats", controller: "eleve/certificats",
                            only: [:index, :show, :create]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end

