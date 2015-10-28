require "simplecov"

SimpleCov.start do
  add_filter "spec/"
  add_filter "bin/"
  add_group "lib", "lib"
end

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "optivo_api"
require "webmock/rspec"
require "vcr"

Dir[File.join(File.expand_path("../support/", __FILE__), "**/*.rb")].each { |f| require f }

WebMock.disable_net_connect!

OptivoApi.configure do |config|
  config.mandator_id = "666"
  config.user = "my_user@test.com"
  config.password = "secret"
  config.logger = Logger.new("/dev/null")
end

VCR.configure do |c|
  c.cassette_library_dir = "spec/fixtures/cassettes"
  c.hook_into :webmock
  c.filter_sensitive_data("<FILTERED>") { OptivoApi.config[:mandator_id] }
  c.filter_sensitive_data("<FILTERED>") { OptivoApi.config[:user] }
  c.filter_sensitive_data("<FILTERED>") { OptivoApi.config[:password] }
end
