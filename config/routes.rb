Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  # Plateforme LMS
  scope "/plateforme", module: "platform", as: "platform" do
    get "/"            => "dashboard#index",  as: "dashboard"
    get "/catalogue"   => "catalogue#index",  as: "catalogue"
    get "/formation"   => "formation#index",  as: "formation"
    get "/messagerie"  => "messagerie#index", as: "messagerie"
    get "/admin"       => "admin#index",      as: "admin"
    get "/profil"      => "profil#index",     as: "profil"

    # Générateur IA
    get  "/generateur" => "generateur#index", as: "generateur"

    # Supports de cours + Modules imbriqués
    resources :supports, path: "supports", only: [:index, :show, :new, :create, :edit, :update, :destroy] do
      member do
        post :generer_modules, controller: "generateur"
      end
      resources :modules, path: "modules", controller: "modules",
                          only: [:show, :edit, :update, :destroy] do
        member do
          post :generer_quiz, controller: "generateur"
        end
      end
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
