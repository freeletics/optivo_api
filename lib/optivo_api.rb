require 'savon'
require 'active_support/all'
require 'optivo_api/request'

Dir.glob(File.join(File.join(File.dirname(__FILE__)), 'optivo_api', '**/*.rb')).each do |f|
  require f
end

module OptivoApi
  extend Configuration

  def self.log(msg)
    if OptivoApi.config[:logger]
      if OptivoApi.config[:logger].respond_to?(:tagged)
        OptivoApi.config[:logger].tagged('OPTIVO') do
          OptivoApi.config[:logger].info(msg)
        end
      else
        OptivoApi.config[:logger].info(msg)
    end
   end
  end
end
