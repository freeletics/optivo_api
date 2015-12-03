module Configuration
  VALID_OPTIONS_KEYS = [
    :mandator_id,
    :user,
    :password,
    :logger,
    :log_level,
    :cache,
    :disabled
  ]

  attr_accessor(*VALID_OPTIONS_KEYS)

  def configure
    yield self
  end

  def config
    VALID_OPTIONS_KEYS.inject({}) do |option, key|
      value = send(key) || defaults[key]
      option.merge!(key => value)
    end
  end

  private

  def defaults
    {log_level: :info, disabled: false}
  end
end
