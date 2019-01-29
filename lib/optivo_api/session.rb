class OptivoApi::Session
  attr_reader :session_id

  def initialize(config = {})
    @config = config
  end

  def login
    fetch_session_id.tap do |sid|
      OptivoApi.log "fetched session_id: #{sid}"
      @session_id = sid
    end
  end

  def logout
    if session_id
      OptivoApi::Request.fetch!(webservice: "Session", call_name: :logout)
      @session_id = nil
      true
    end
  end

  def cache_key
    "optivo_api_session_id_#{config[:mandator_id].to_s.strip}"
  end

  private

  def fetch_session_id
    raise OptivoApi::CredentialsMissing, "Credentials are missing" if credentials_missing?

    response = OptivoApi::Request.fetch! webservice: "Session", call_name: :login, attributes: credentials, auth: false
    response.value.to_s
  end

  def credentials_missing?
    credentials[:mandator_id].nil? || credentials[:user].nil? || credentials[:password].nil?
  end

  def config
    OptivoApi.config.merge @config
  end

  def credentials
    config.select { |key, _v| %i[mandator_id user password].include?(key) }
  end
end
