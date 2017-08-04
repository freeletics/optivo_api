source "https://rubygems.org"

gemspec

group :test, :development do
  gem "guard-rspec"
  gem "guard-rubocop"
  gem "rubocop", ">= 0.49.1"
end

group :test do
  gem "simplecov", require: false
  gem "vcr"
  gem "webmock"
end
