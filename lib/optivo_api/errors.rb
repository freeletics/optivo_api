module OptivoApi
  class Error < StandardError; end
  class UnknownError < Error; end
  class AuthenticationError < Error; end
  class InvalidSession < Error; end
  class InvalidEmail < Error; end
  class RecipientNotFound < Error; end
  class CredentialsMissing < Error; end
  class RecipientNotInList < Error; end
  class RecipientIsAlreadyOnThisList < Error; end
  class RecipientExceededBounceLimit < Error; end
  class RecipientIsOnTheBlacklist < Error; end
end
