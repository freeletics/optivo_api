module OptivoApi
  module Configuration
    VALID_OPTIONS_KEYS = [
      :mandator_id,
      :user,
      :password,
      :logger,
      :log_level,
      :cache
    ]

    attr_accessor *VALID_OPTIONS_KEYS

    def configure
      yield self
    end

    def config
      VALID_OPTIONS_KEYS.inject({}) do |option, key|
        option.merge!(key => send(key))
      end
    end
  end
end
