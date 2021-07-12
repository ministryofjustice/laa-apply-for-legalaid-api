source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.1'

gem 'aasm', '~> 5.2.0'
gem 'active_model_serializers', '~> 0.10.12'
gem 'after_commit_everywhere', '~> 1.0'
gem 'discard', '~> 1.2'
gem 'geckoboard-ruby'
gem 'govuk_notify_rails', '~> 2.1.2'
gem 'loofah', '>= 2.2.3'
gem 'pg'
gem 'pg_dump_anonymize'
gem 'puma', '~> 5.3'
gem 'rails', '~> 6.1.4'
gem 'regexp-examples'
gem 'rexml'
gem 'savon', '~> 2.12.1'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'sentry-sidekiq'
gem 'simple_command', github: 'nebulab/simple_command', branch: 'master'
gem 'tzinfo-data'
gem 'webdack-uuid_migration', '~> 1.4.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Authentication
gem 'devise', '>= 4.7.1' # User authentication
gem 'devise_saml_authenticatable', '>= 1.6.2'
gem 'omniauth', '>= 2.0.0'
gem 'omniauth-google-oauth2', '>= 0.8.1'
gem 'omniauth-oauth2', '>= 1.7.1' # Provide Oauth2 strategy framework
gem 'omniauth-rails_csrf_protection', '~> 1.0', '>= 0.1.2'

# Improve backtrace in nested error recues
gem 'nesty'

# Authorization
gem 'pundit'

# Pagination
gem 'pagy'

# Seeding tools
gem 'dibber'
# Gathers data from user browser - OS and Browser name
gem 'browser'

# Used to mock saml request in UAT
gem 'ruby-saml-idp', github: 'dev-develop/ruby-saml-idp', branch: 'master'

# Used to encrypt JSON stored in SecureData
gem 'jwt'

# background processing
gem 'redis-namespace'
gem 'sidekiq', '~> 6.2.1'
gem 'sidekiq_alive', '>= 2.0.1'
gem 'sidekiq-status', '>= 1.1.4'

# URL and path parsing
gem 'addressable'

# File storage
gem 'aws-sdk-s3'

# convert documents to PDF
gem 'libreconv'

# Used for working day calculations
gem 'business'

# Monitoring
gem 'prometheus_exporter', '=0.4.17'
gem 'webrick'

# Generating Fake applications for tests and admin user
gem 'factory_bot_rails', '>= 5.2.0'
gem 'faker', '>=1.9.1'

gem 'webpacker', '~> 5'

gem 'wdm', '>= 0.1.0' if Gem.win_platform?

# generating PDFs
gem 'wicked_pdf'

# interface to manage data
gem 'rails_admin', '~> 2.1'

# Manage security headers
gem 'secure_headers'

# DFE formbuilder
gem 'govuk_design_system_formbuilder'

# Sprockets isn't used by the app but is installed by rails as a dependency.
# Versions >= 4 cause issues if app/assets/config/manifest.js is not present.
# This pins sprockets to an earlier version to prevent those errors
gem 'sprockets', '< 4'

group :development, :test do
  gem 'awesome_print', '~> 1.9.2'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails', '>= 2.7.5'
  gem 'erb_lint', '0.0.37', require: false
  gem 'hirb'
  gem 'htmlentities'
  gem 'i18n-tasks', '>= 0.9.31'
  gem 'json_expressions'
  gem 'nokogiri'
  gem 'overcommit'
  gem 'pry-byebug'
  gem 'rspec_junit_formatter'
  gem 'rubocop', require: false
  gem 'rubocop-performance'
  gem 'rubocop-rails', require: false

  # Available in dev env for generators
  gem 'rspec-rails', '~> 5.0'
end

group :development do
  gem 'guard-cucumber'
  gem 'guard-livereload'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'listen', '>= 3.0.5', '< 3.6'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'axe-core-cucumber'
  gem 'capybara', '>= 3.32.2', '< 4.0'
  gem 'climate_control' # Allows environment variables to be modified within specs
  gem 'codecov', require: false
  gem 'cucumber', require: false
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'launchy'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'simplecov', require: false
  gem 'simplecov-rcov'
  gem 'vcr'
  gem 'webdrivers', '~> 4.6'
  gem 'webmock'
end
