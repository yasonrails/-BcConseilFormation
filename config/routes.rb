Rails.application.routes.draw do
  devise_for :users
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
    end

    # ── ÉLÈVE ────────────────────────────────────
    get  "/catalogue"     => "eleve/catalogue#index",     as: "catalogue"
    get  "/mes-formations" => "eleve/mes_formations#index", as: "mes_formations"
    post "/inscription/:id" => "eleve/inscriptions#create", as: "inscription"
    get  "/module/:id"    => "eleve/modules#show",        as: "module"
    post "/module/:id/progression" => "eleve/progressions#create", as: "module_progression"
    get  "/profil"        => "eleve/profil#index",        as: "profil"
  end

  get "up" => "rails/health#show", as: :rails_health_check
end

