require "simplecov"
require "cgi"

SimpleCov.start do
  add_filter "spec/"
  add_filter "bin/"
  add_group "lib", "lib"
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "optivo_api"
require "webmock/rspec"
require "vcr"

Dir[File.join(File.expand_path("support/", __dir__), "**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end

  config.order = :random
  config.disable_monkey_patching!

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end

WebMock.disable_net_connect!

OptivoApi.configure do |config|
  config.mandator_id = ENV["OPTIVO_MANDATOR_ID"] || "666"
  config.user = ENV["OPTIVO_MANDATOR_USER"] || "my_user@test.com"
  config.password = ENV["OPTIVO_MANDATOR_PASSWORD"] || "secret"
  config.logger = Logger.new("/dev/null")
  config.log_level = :debug
end

VCR.configure do |c|
  c.cassette_library_dir = File.expand_path("fixtures/cassettes", __dir__)
  c.hook_into :webmock
  c.default_cassette_options = {record: :once}
  c.filter_sensitive_data("<FILTERED>") { OptivoApi.config[:mandator_id] }
  c.filter_sensitive_data("<FILTERED>") { OptivoApi.config[:user] }
  # Fixes filtering of special chars
  c.filter_sensitive_data("<FILTERED>") { CGI.escapeHTML(OptivoApi.config[:password]) }
end
