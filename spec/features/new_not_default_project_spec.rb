# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Create new project without default configuration' do
  before(:all) do
    drop_dummy_database
    remove_project_directory
    run_cybele('--database=sqlite3 --skip-create-database --skip-sidekiq --skip-simple-form --skip-show-for')
    setup_app_dependencies
  end

  it 'uses sqlite3 instead of default pg in Gemfile' do
    gemfile_file = content('Gemfile')
    expect(gemfile_file).not_to match(/^gem 'pg'/)
    expect(gemfile_file).to match(/^gem 'sqlite3'/)
  end

  it 'uses sqlite3 database template' do
    database_file = content('config/database.yml')
    expect(database_file).to match(/^default: &default/)
    expect(database_file).to match(/adapter: sqlite3/)
  end

  it 'do not use sidekiq' do
    gemfile_file = content('Gemfile')
    expect(gemfile_file).not_to match(/^gem 'sidekiq'/)
    expect(gemfile_file).not_to match(/^gem 'sidekiq-cron'/)
    expect(gemfile_file).not_to match(/^gem 'cocaine'/)

    expect(File).not_to exist(file_project_path('config/sidekiq.yml'))

    expect(File).not_to exist(file_project_path('config/sidekiq_schedule.yml'))
    expect(File).not_to exist(file_project_path('config/initializers/sidekiq.rb'))
    expect(File).not_to exist(file_project_path('lib/tasks/sidekiq.rake'))

    routes_file = content('config/routes.rb')
    expect(routes_file).not_to match("^require 'sidekiq/web'")
    expect(routes_file).not_to match("^require 'sidekiq/cron/web'")
  end

  it 'uses responders' do
    gemfile_file = content('Gemfile')
    expect(gemfile_file).to match(/^gem 'responders'/)

    lib_file = content('lib/application_responder.rb')
    expect(lib_file).to match(/^class ApplicationResponder/)

    controller_file = content('app/controllers/application_controller.rb')
    expect(controller_file).to match("^require 'application_responder'")
    expect(controller_file).to match('self.responder = ApplicationResponder')
    expect(controller_file).to match('respond_to :html, :js, :json')

    expect(File).to exist(file_project_path('config/locales/responders.en.yml'))
    expect(File).to exist(file_project_path('config/locales/responders.tr.yml'))
    locale_file = content('config/locales/responders.tr.yml')
    expect(locale_file).not_to match('# alert:')
    expect(locale_file).to match('create:')
    expect(locale_file).to match('update:')
    expect(locale_file).to match('destroy:')
  end

  it 'uses rollbar' do
    gemfile_file = content('Gemfile')
    expect(gemfile_file).to match(/^gem 'rollbar'/)

    config_file = content('config/initializers/rollbar.rb')
    expect(config_file).to match(/^Rollbar.configure/)
  end

  it 'uses ransack' do
    gemfile_file = content('Gemfile')
    expect(gemfile_file).to match(/^gem 'ransack'/)
  end

  it 'uses will_paginate' do
    gemfile_file = content('Gemfile')
    expect(gemfile_file).to match(/^gem 'will_paginate'/)
  end

  it 'uses to_xls' do
    gemfile_file = content('Gemfile')
    expect(gemfile_file).to match(/^gem 'to_xls'/)
  end

  it 'uses roo' do
    gemfile_file = content('Gemfile')
    expect(gemfile_file).to match(/^gem 'roo'/)
  end

  it 'uses roo-xls' do
    gemfile_file = content('Gemfile')
    expect(gemfile_file).to match(/^gem 'roo-xls'/)
  end

  it 'uses write_xlsx' do
    gemfile_file = content('Gemfile')
    expect(gemfile_file).to match(/^gem 'write_xlsx'/)
  end

  it 'uses colorize' do
    gemfile_file = content('Gemfile')
    expect(gemfile_file).to match("gem 'colorize'")
  end

  it 'uses better_errors' do
    gemfile_file = content('Gemfile')
    expect(gemfile_file).to match("gem 'better_errors'")
  end

  it 'do not use show_for' do
    gemfile_file = content('Gemfile')
    expect(gemfile_file).not_to match(/^gem 'show_for'/)

    expect(File).not_to exist(file_project_path('config/initializers/show_for.rb'))
    expect(File).not_to exist(file_project_path('config/locales/show_for.en.yml'))
    expect(File).not_to exist(file_project_path('config/locales/show_for.tr.yml'))
  end

  it 'uses config and staging file' do
    gemfile_file = content('Gemfile')
    expect(gemfile_file).to match(/^gem 'config'/)

    config_development_file = content('config/environments/development.rb')
    expect(config_development_file).to match(/^Rails.application.configure/)

    config_staging_file = content('config/environments/staging.rb')
    expect(config_staging_file).to match(/^Rails.application.configure/)

    config_production_file = content('config/environments/production.rb')
    expect(config_production_file).to match(/^Rails.application.configure/)

    config_test_file = content('config/environments/test.rb')
    expect(config_test_file).to match(/^Rails.application.configure/)
  end

  it 'uses locale_language' do
    expect(File).to exist(file_project_path('config/locales/en.yml'))
    expect(File).to exist(file_project_path('config/locales/tr.yml'))
    locale_file = content('config/locales/tr.yml')
    expect(locale_file).to match('phone:')
    expect(locale_file).to match('date:')
    expect(locale_file).to match('time:')
    expect(locale_file).to match('number:')

    expect(File).to exist(file_project_path('config/locales/email.en.yml'))
    locale_file = content('config/locales/email.en.yml')
    expect(locale_file).to match('email:')

    expect(File).to exist(file_project_path('config/locales/email.tr.yml'))
    locale_file = content('config/locales/email.tr.yml')
    expect(locale_file).to match('email:')

    expect(File).to exist(file_project_path('config/locales/models.en.yml'))
    locale_file = content('config/locales/models.en.yml')
    expect(locale_file).to match('activerecord:')

    expect(File).to exist(file_project_path('config/locales/models.tr.yml'))
    locale_file = content('config/locales/models.tr.yml')
    expect(locale_file).to match('activerecord:')

    expect(File).to exist(file_project_path('config/locales/view.en.yml'))
    locale_file = content('config/locales/view.en.yml')
    expect(locale_file).to match('view:')

    expect(File).to exist(file_project_path('config/locales/view.tr.yml'))
    locale_file = content('config/locales/view.tr.yml')
    expect(locale_file).to match('view:')
  end

  it 'uses recipient_interceptor' do
    gemfile_file = content('Gemfile')
    expect(gemfile_file).to match(/^gem 'recipient_interceptor'/)

    config_staging_file = content('config/environments/staging.rb')
    expect(config_staging_file).to match('RecipientInterceptor.new')
  end

  it 'uses cybele_version' do
    expect(File).to exist(file_project_path('VERSION.txt'))
  end

  it 'do not use simple_form' do
    gemfile_file = content('Gemfile')
    expect(gemfile_file).not_to match(/^gem 'simple_form'/)

    expect(File).not_to exist(file_project_path('config/initializers/simple_form.rb'))
    expect(File).not_to exist(file_project_path('config/initializers/simple_form_bootstrap.rb'))
    expect(File).not_to exist(file_project_path('config/locales/simple_form.en.yml'))
    expect(File).not_to exist(file_project_path('config/locales/simple_form.tr.yml'))
  end

  it 'make control secret_key_base for staging' do
    secret_file = content('config/secrets.yml')
    expect(secret_file).to match('staging')
  end
end
