source 'https://rubygems.org'

gem 'rails', '4.1.5'

gem 'airbrake', '~> 4.2.1'
gem 'logstasher', '0.6.2'
gem 'unicorn', '~> 4.9.0'
gem 'sass-rails', '~> 4.0.3'
gem 'mongoid', '5.0.1'
gem 'uglifier', '>= 1.3.0'

# GDS managed dependencies
gem 'plek', '~> 1.10'
gem 'gds-sso', '11.0.0'
gem 'govuk_admin_template', '~> 3.3.1'

if ENV["GOVSPEAK_DEV"]
  gem "govspeak", :path => "../govspeak"
else
  gem "govspeak", "3.4.0"
end

if ENV["API_DEV"]
  gem "gds-api-adapters", :path => "../gds-api-adapters"
else
  gem "gds-api-adapters", "24.4.0"
end

group :development, :test do
  gem 'better_errors', '~> 2.1.1'
  gem 'binding_of_caller', '~> 0.7.2'
  gem 'foreman', '0.74.0'
  gem 'rspec-rails', '~> 3.3'
  gem 'simplecov', '0.10.0', require: false
  gem 'simplecov-rcov', '0.2.3', require: false
end
