require "savon"
require "optivo_api/configuration"

module OptivoApi
  extend Configuration

  def self.log(msg)
    if OptivoApi.config[:logger]
      if OptivoApi.config[:logger].respond_to?(:tagged)
        OptivoApi.config[:logger].tagged("OPTIVO") { OptivoApi.config[:logger].info(msg) }
      else
        OptivoApi.config[:logger].send(OptivoApi.config[:log_level], msg)
      end
    end
  end
end

require File.join(File.dirname(__FILE__), "optivo_api", "web_services", "base.rb")

Dir.glob(File.join(File.join(File.dirname(__FILE__)), "optivo_api", "**/*.rb")).each do |f|
  require f
end
