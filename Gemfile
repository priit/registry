source 'https://rubygems.org'

# core
gem 'active_interaction', '~> 4.0'
gem 'apipie-rails', '~> 0.5.18'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'iso8601', '0.13.0' # for dates and times
gem 'mime-types-data'
gem 'mimemagic', '0.4.3'
gem 'rails', '~>  6.1.3.2'
gem 'rest-client'
gem 'uglifier'

# load env
gem 'figaro', '~> 1.2'

# model related
gem 'paper_trail', '~> 12.0'
gem 'pg',                        '1.2.3'
# 1.8 is for Rails < 5.0
gem 'ransack', '~> 2.3'
gem 'truemail', '~> 2.4' # validates email by regexp, mail server existence and address existence
gem 'validates_email_format_of', '1.6.3' # validates email against RFC 2822 and RFC 3696

# 0.7.3 is the latest for Rails 4.2, however, it is absent on Rubygems server
# https://github.com/huacnlee/rails-settings-cached/issues/165
gem 'nokogiri', '~> 1.11.7'

# style
gem 'bootstrap-sass', '~> 3.4'
gem 'coderay',          '1.1.3'   # xml console visualize
gem 'coffee-rails', '>= 5.0'
gem 'jquery-rails'
gem 'selectize-rails', '0.12.6' # include selectize.js for select
gem 'kaminari'
gem 'sass-rails'
gem 'select2-rails',    '4.0.13' # for autocomplete
gem 'cancancan'
gem 'devise', '~> 4.8'

# registry specfic
gem 'data_migrate', '~> 7.0'
gem 'dnsruby', '~> 1.61'
gem 'isikukood' # for EE-id validation
gem 'simpleidn', '0.2.1' # For punycode
gem 'money-rails'
gem 'whenever', '1.0.0', require: false

# country listing
gem 'countries', :require => 'countries/global'

# id + mid login
# gem 'digidoc_client', '0.3.0'
gem 'digidoc_client',
    github: 'tarmotalu/digidoc_client',
    ref: '1645e83a5a548addce383f75703b0275c5310c32'

# TARA
gem 'omniauth'
gem 'omniauth-rails_csrf_protection'
gem 'omniauth-tara', github: 'internetee/omniauth-tara'


gem 'epp', github: 'internetee/epp', branch: :master
gem 'epp-xml', '1.2.0', github: 'internetee/epp-xml', branch: :master
gem 'que'
gem 'daemons-rails', '1.2.1'
gem 'que-web'
gem 'sidekiq'
gem 'pdfkit'
gem 'jquery-ui-rails', '6.0.1'
gem 'airbrake'

gem 'company_register', github: 'internetee/company_register',
                        branch: 'master'
gem 'e_invoice', github: 'internetee/e_invoice', branch: :master
gem 'lhv', github: 'internetee/lhv', branch: 'master'
gem 'domain_name'
gem 'haml', '~> 5.0'
gem 'rexml'
gem 'wkhtmltopdf-binary', '~> 0.12.5.1'

gem 'directo', github: 'internetee/directo', branch: 'master'

group :development, :test do
  gem 'pry', '0.14.1'
  gem 'puma'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'minitest', '~> 5.14'
  gem 'simplecov', '0.17.1', require: false # CC last supported v0.17
  gem 'webdrivers'
  gem 'webmock'
end

gem 'aws-sdk-sesv2', '~> 1.16'
