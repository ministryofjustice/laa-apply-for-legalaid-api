Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/support', as: 'rails_admin'

  root to: 'providers/start#index'

  require 'sidekiq/web'
  require 'sidekiq-status/web'
  mount Sidekiq::Web => '/sidekiq'

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == 'sidekiq' && password == ENV['SIDEKIQ_WEB_UI_PASSWORD'].to_s
  end

  get '/saml/auth' => 'saml_idp#new'
  post '/saml/auth' => 'saml_idp#create'

  devise_for :providers, controllers: { saml_sessions: 'saml_sessions' }
  devise_for :applicants
  devise_for :admin_users, controllers: { sessions: 'admin_users/sessions' }

  devise_scope :applicant do
    match(
      'auth/true_layer/callback',
      to: 'applicants/omniauth_callbacks#true_layer',
      via: %i[get puts],
      as: :applicant_true_layer_omniauth_callback
    )
  end

  devise_scope :admin_user do
    match(
      'auth/google_oauth2/callback',
      to: 'admin_users/omniauth_callbacks#google_oauth2',
      via: %i[get puts],
      as: :admin_user_google_oauth2_omniauth_callback
    )
  end

  get 'auth/failure', to: 'auth#failure'
  get 'ping', to: 'status#ping', format: :json
  get 'healthcheck', to: 'status#status', format: :json
  get 'status', to: 'status#ping', format: :json

  resource :contact, only: [:show]
  resources :accessibility_statement, only: [:index]
  resources :privacy_policy, only: [:index]
  resources :feedback, only: %i[new create show]
  resources :errors, only: [:show], path: :error
  resources :problem, only: :index

  namespace :admin do
    root to: 'legal_aid_applications#index'
    post 'search', to: 'legal_aid_applications#search', as: 'application_search'
    namespace :legal_aid_applications do
      resources :submissions, only: [:show] do
        member do
          get 'download_xml_response'
          get 'download_xml_request'
          get 'download_means_report'
          get 'download_merits_report'
        end
      end
    end
    resources :legal_aid_applications, only: %i[index destroy] do
      post :create_test_applications, on: :collection
      delete :destroy_all, on: :collection
    end
    resource :settings, only: %i[show update]
    resource :submitted_applications_report, only: %i[show]
    resource :feedback, controller: :feedback, only: %i[show]
    resources :ccms_connectivity_tests, only: [:show]
    resources :reports, only: %i[index create] do
      member do
        get 'download_custom_report'
      end
    end
    get 'user_dashboard', to: 'user_dashboard#index', as: 'user_dashboard'
    resources :roles, only: %i[index create update]
    namespace :roles do
      resources :permissions, only: %i[show update]
    end
    resources :providers, only: %i[new create]
    resources :firms, only: :index do
      resources :providers, only: :index
    end

    post 'provider/check', to: 'providers#check', as: 'provider_check'
    get 'admin_report_submitted', to: 'reports#download_submitted', as: 'reports_submitted_csv'
    get 'admin_reports_non_passported', to: 'reports#download_non_passported', as: 'reports_non_passported_csv'
  end

  namespace 'v1' do
    resources :proceeding_types, only: [:index]
    resources :workers, only: [:show]
  end

  namespace :citizens do
    resources :legal_aid_applications, only: %i[show index]
    resources :resend_link_requests, only: %i[show update], path: 'resend_link'
    resource :consent, only: %i[show update]
    resource :contact_provider, only: [:show]
    resources :banks, only: %i[index create]
    resource :property_value, only: %i[show update]
    resources :accounts, only: [:index]
    resources :gather_transactions, only: [:index]
    resources :additional_accounts, only: %i[index create new update]
    resource :own_home, only: %i[show update]
    resource :percentage_home, only: %i[show update]
    resource :outstanding_mortgage, only: %i[show update]
    resource :savings_and_investment, only: %i[show update]
    resource :shared_ownership, only: %i[show update]
    resource :restrictions, only: %i[show update]
    resource :other_assets, only: %i[show update]
    resource :policy_disregards, only: %i[show update]
    resources :check_answers, only: [:index] do
      patch :reset, on: :collection
      patch :continue, on: :collection
    end
    resource :identify_types_of_income, only: %i[show update]
    resource :cash_income, only: %i[show update]
    resource :cash_outgoing, only: %i[show update]
    resource :student_finance, only: %i[show update]
    namespace :student_finances do
      resource :annual_amount, only: %i[show update]
    end
    resource :identify_types_of_outgoing, only: %i[show update]
    resources :income_summary, only: :index
    resources :outgoings_summary, only: :index
    resource :incoming_transactions, only: [] do
      get '/:transaction_type', to: 'incoming_transactions#show', as: ''
      patch '/:transaction_type', to: 'incoming_transactions#update'
    end
    resource :outgoing_transactions, only: [] do
      get '/:transaction_type', to: 'outgoing_transactions#show', as: ''
      patch '/:transaction_type', to: 'outgoing_transactions#update'
    end
    resource :means_test_result, only: [:show]
  end

  namespace :providers do
    root to: 'start#index'
    resource :provider, only: [:show], path: 'your_profile'
    resources :applicants, only: %i[new create]
    resource :confirm_office, only: %i[show update]
    resource :select_office, only: %i[show update]
    resource :declaration, only: %i[show update]
    resource :invalid_login, only: :show

    resources :legal_aid_applications, path: 'applications', only: %i[index create] do
      get :search, on: :collection
      resource :delete, controller: :delete, only: %i[show destroy]
      resources :proceedings_types, only: %i[index create update]
      resource :has_other_proceedings, only: %i[show update destroy]
      resource :property_value, only: %i[show update]
      resource :limitations, only: %i[show update]
      resource :applicant_details, only: %i[show update]
      resource :address, only: %i[show update]
      resource :address_lookup, only: %i[show update]
      resource :address_selection, only: %i[show update]
      resource :outstanding_mortgage, only: %i[show update]
      resource :has_dependants, only: %i[show update]
      resources :dependants, only: %i[new show update]
      resources :remove_dependants, only: %i[show update]
      resource :has_other_dependants, only: %i[show update]
      resource :own_home, only: %i[show update]
      resource :check_benefit, only: %i[index update]
      resource :other_assets, only: %i[show update]
      resource :policy_disregards, only: %i[show update]
      resource :statement_of_case, only: %i[show update destroy], controller: 'application_merits_task/statement_of_cases'
      resources :check_benefits, only: [:index]
      resources :applicant_employed, only: %i[index create]
      resource :open_banking_consents, only: %i[show update], path: 'does-client-use-online-banking'
      resource :merits_declaration, only: %i[show update]
      resource :capital_introduction, only: %i[show update]
      resources :check_provider_answers, only: [:index] do
        post :reset, on: :collection
        patch :continue, on: :collection
      end
      resource :restrictions, only: %i[show update]
      resource :about_the_financial_assessment, only: %i[show update]
      resource :email_address, only: %i[show update]
      resource :application_confirmation, only: :show
      resource :percentage_home, only: %i[show update]
      resource :vehicle, only: %i[show update]
      namespace :vehicles do
        resource :estimated_value, only: %i[show update]
        resource :remaining_payment, only: %i[show update]
        resource :age, only: %i[show update]
        resource :regular_use, only: %i[show update]
      end
      resource :applicant_bank_account, only: %i[show update]
      resource :offline_savings_account, only: %i[show update]
      resource :offline_account, only: %i[show update]
      resource :savings_and_investment, only: %i[show update]
      resource :shared_ownership, only: %i[show update]
      resource :check_passported_answers, only: [:show] do
        patch :continue
        patch :reset
      end
      resource :capital_assessment_result, only: %i[show update]
      resource :capital_income_assessment_result, only: %i[show update]
      resource :identify_types_of_income, only: %i[show update]
      resource :identify_types_of_outgoing, only: %i[show update]
      resource :opponent, only: %i[show update], controller: 'application_merits_task/opponents'
      resource :opponent_name, only: %i[show update]
      resource :date_client_told_incident, only: %i[show update], controller: 'application_merits_task/date_client_told_incidents'
      resource :check_merits_answers, only: [:show] do
        patch :continue
        patch :reset
      end
      resource :start_chances_of_success, only: %i[show update]
      resource :client_completed_means, only: %i[show update]
      resources :income_summary, only: %i[index create]
      resource :no_income_summary, only: %i[show update]
      resources :outgoings_summary, only: %i[index create]
      resource :no_outgoings_summary, only: %i[show update]
      resource :incoming_transactions, only: [] do
        get '/:transaction_type', to: 'incoming_transactions#show', as: ''
        patch '/:transaction_type', to: 'incoming_transactions#update'
      end
      resource :outgoing_transactions, only: [] do
        get '/:transaction_type', to: 'outgoing_transactions#show', as: ''
        patch '/:transaction_type', to: 'outgoing_transactions#update'
      end
      resources :bank_transactions, only: [] do
        patch 'remove_transaction_type', on: :member
      end
      resource :means_summary, only: %i[show update]
      resource :used_delegated_functions, only: %i[show update]
      resource :delegated_functions_date, only: %i[show update]
      resource :use_ccms, only: %i[show]
      resources :use_ccms_employed, only: %i[index]
      resource :substantive_application, only: %i[show update]
      resource :end_of_application, only: %i[show update]
      resource :submitted_application, only: :show
      resources :delegated_confirmation, only: :index
      resource :merits_report, only: :show
      resource :means_report, only: :show
      resource :non_passported_client_instructions, only: :show
      resource :confirm_dwp_non_passported_applications, only: %i[show update]
      resource :check_client_details, only: %i[show update]
      resource :received_benefit_confirmation, only: %i[show update]
      resource :has_evidence_of_benefit, only: %i[show update]
    end

    resources :application_proceeding_types, path: 'application_proceeding_types', only: %i[] do
      resources :chances_of_success, only: %i[index create], controller: 'proceeding_merits_task/chances_of_success'
      resource :success_prospects, only: %i[show update], controller: 'proceeding_merits_task/success_prospects'
      resource :proceedings_before_the_court, only: %i[show update]
    end
  end

  # dummy route to set session vars available in test environment only
  if Rails.env.test?
    namespace :test do
      resource :session, only: %i[create]
    end
  end

  get '/.well-known/security.txt' => redirect('https://raw.githubusercontent.com/ministryofjustice/security-guidance/master/contact/vulnerability-disclosure-security.txt')

  # Catch all route that traps paths not defined above. Must be last route.
  match '*path', to: 'errors#page_not_found', via: :all
end
