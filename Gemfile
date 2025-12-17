source "https://rubygems.org"

# Version constraints based on current Gemfile.lock to prevent major version updates
gem "sinatra", "~> 4.2.0"
gem "mechanize", "~> 2.14.0"
gem "unicode_utils", "~> 1.4.0"
gem "unicorn", "~> 6.1.0"

group :development, :test do
    gem "rspec", "~> 3.13.0"
    gem "rubocop", "~> 1.74.0"
    gem "pry", "~> 0.15.2"
end

group :test do
  gem 'minitest'
  gem 'webmock'
  gem 'rack-test'
  gem 'mocha'
end