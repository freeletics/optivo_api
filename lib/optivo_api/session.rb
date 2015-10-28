module OptivoApi
  class Session
    attr_reader :session_id

    def login
      fetch_session_id.tap do |sid|
        OptivoApi.log "fetched session_id: #{sid}"
         @session_id = sid
      end
    end

    def logout
      if session_id
        Request.fetch!(webservice: "Session", call_name: :logout)
        @session_id = nil
        true
      end
    end

    private

    def fetch_session_id
      raise CredentialsMissing, "Credentials are missing" if credentials_missing?
      response = Request.fetch! webservice:  "Session", call_name: :login, attributes: credentials, auth: false
      response.value
    end

    def credentials_missing?
      credentials[:mandator_id].blank? || credentials[:user].blank?  || credentials[:password].blank?
    end

    def credentials
      @credentials ||= OptivoApi.config.slice(:mandator_id, :user, :password)
    end
  end
end
