module OptivoApi
  class Client
    attr_accessor :logger
    attr_reader :request

    def call(request)
      @request = request
      build_response
    end

    private

    def build_response
      OptivoApi::Response.build raw_response: soap_response, request: request
    end

    def soap_response
      retry_on_invalid_session do
        savon_client(request.optivo_url).call(request.call_name, message: message).tap do |raw|
          raise_optivo_error(raw) if error_present?(raw)
        end
      end
    end

    def message
      request.attributes.tap do |result|
        if request.auth?
          result["sessionId"] = fetch_session_id
          OptivoApi.log("use sessionId: #{result['sessionId']} for #{request.call_name}")
        end
      end
    end

    def fetch_session_id(force:false)
      if cache?
        fetch_cached(force: force)
      else
        session.login
      end
    end

    def fetch_cached(force:)
      cache.fetch "optivo_api_session_id", expires_in: 10.minutes, force: force do
        session.login
      end
    end

    def session
      @session ||= OptivoApi::Session.new
    end

    def retry_on_invalid_session(&_block)
      i = 0
      while i < 4
        begin
          return yield
        rescue OptivoApi::InvalidSession
          raise if i > 2
          sleep(1)
          OptivoApi.log "refetch_session_id for #{i + 1}. time"
          fetch_session_id force: true
        end
        i += 1
      end
    end

    def error_present?(raw_response)
      raw_response.body.keys[0] == :fault
    end

    def raise_optivo_error(raw_response)
      error_message = raw_response.body[:fault][:faultstring]
      case error_message
      when /Invalid sessionId/
        # OptivoApi::Error: optivo.core.util.DontLogMeException: broadmail.api.soap11.impl.InvalidWebserviceSessionException: Invalid sessionId: 1
        raise OptivoApi::InvalidSession, error_message
      when /Invalid credentials/
        raise OptivoApi::AuthenticationError, error_message
      else
        raise OptivoApi::UnknownError, error_message
      end
    end

    def savon_client(wdsl)
      Savon::Client.new do |savon|
        savon.ssl_verify_mode :none
        savon.wsdl wdsl
        savon.raise_errors false
        savon.filters [:mandatorId, :password]
        savon.convert_request_keys_to :lower_camelcase
        savon.strip_namespaces true
        savon.pretty_print_xml true
        savon.logger OptivoApi.config[:logger]
        savon.log true if OptivoApi.config[:logger]
        savon.log_level :info if OptivoApi.config[:logger]
        savon.open_timeout 180 # seconds
        savon.read_timeout 180 # seconds
      end
    end

    def cache?
      cache.respond_to? :fetch
    end

    def cache
      OptivoApi.config[:cache]
    end
  end
end
