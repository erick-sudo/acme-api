Rails.application.routes.draw do
  resources :invoices
  resources :customers
  resources :users
  resources :revenues
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  get "/invoices/paged/all_count", to: "invoices#count"
  get "/invoices/paged/search_count", to: "invoices#search_count"
  get "/invoices/paged/search_invoices", to: "invoices#search_invoices"
  get "/invoices/paged/latest_invoices", to: "invoices#latest_invoices"

  get "/customers/paged/all_count", to: "customers#count"
  get "/customers/paged/search_count", to: "customers#search_count"
  get "/customers/paged/search_customers", to: "customers#search_customers"

  post "/users/by/email", to: "users#show_user_email"

  get "/dashboard/counts", to: "dashboard#counts"
end
