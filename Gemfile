source 'https://rubygems.org'

gem 'rails', '3.2.16'

gem 'exception_notification', '2.6.1'
gem 'aws-ses', :require => 'aws/ses'
gem 'unicorn'

gem 'gds-sso', '9.2.1'

gem 'mongoid', '2.5.2'

gem 'generic_form_builder', '0.7.0'

if ENV['CONTENT_MODELS_DEV']
  gem 'govuk_content_models', :path => '../govuk_content_models'
else
  gem "govuk_content_models", '6.4.0'
end

group :assets do
  gem 'sass-rails', '3.2.6'
  gem 'uglifier', '>= 1.3.0'
end

gem 'debugger', group: [:development, :test]

group :test do
  gem 'cucumber-rails', '1.4.0', require: false
  gem 'launchy'
  gem 'rspec-rails', '2.14.1'
  gem 'factory_girl', '4.3.0'
  gem 'database_cleaner', '1.2.0'
end
