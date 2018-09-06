module OptivoApi
  class Error < StandardError; end
  class UnknownError < Error; end
  class AuthenticationError < Error; end
  class InvalidSession < Error; end
  class InvalidEmail < Error; end
  class RecipientNotFound < Error; end
  class CredentialsMissing < Error; end
  class RecipientIsAlreadyOnThisList < Error; end
  class NoUnsubscribeFound < Error; end
  class RecipientExceededBounceLimit < Error; end
  class RecipientIsOnTheBlacklist < Error; end

  class RecipientNotInList < Error
    attr_reader :recipient_ids

    def initialize(message, recipient_ids)
      @recipient_ids = Array(recipient_ids)
      super(message)
    end
  end
end
