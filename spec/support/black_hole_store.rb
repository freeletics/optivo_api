class BlackHoleStore
  def fetch(*_args)
    yield
  end

  def read(*_args); end

  def write(*_args); end

  def delete(*_args); end

  def increment(*_args); end

  def decrement(*_args); end
end
