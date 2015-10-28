module OptivoApi
  class Request
    attr_accessor :attributes, :call_name, :webservice_name

    def initialize(params = {})
      @call_name = params[:call_name]
      @webservice_name = params[:webservice]
      @attributes = params[:attributes] || {}
      @auth       = params.fetch(:auth, true)
    end

    def auth?
      !!@auth
    end

    def optivo_url
      "https://api.broadmail.de/soap11/Rpc#{webservice_name}?WSDL"
    end

    def fetch!
      client.call self
    end

    def self.fetch!(params)
      request = Request.new params
      request.fetch!
    end

    private

    def client
      Client.new
    end
  end
end
