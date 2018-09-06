class OptivoApi::Request
  attr_accessor :attributes, :call_name, :webservice_name, :auth, :config

  def initialize(params = {})
    @call_name = params[:call_name]
    @webservice_name = params[:webservice]
    @attributes = params[:attributes] || {}
    @auth       = params.fetch(:auth, true)
    @config     = params[:config] || {}
  end

  def optivo_url
    # TODO: change to new url
    # "https://api.campaign.episerver.net/soap11/Rpc#{webservice_name}"
    "https://api.broadmail.de/soap11/Rpc#{webservice_name}?WSDL"
  end

  def fetch!
    client.call self
  end

  def self.fetch!(params)
    request = new params
    request.fetch!
  end

  private

  def client
    OptivoApi::Client.new(config)
  end
end
