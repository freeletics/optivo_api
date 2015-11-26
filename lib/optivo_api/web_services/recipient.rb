module OptivoApi::WebServices
  # https://companion.broadmail.de/display/DEMANUAL/RecipientWebservice
  class Recipient < Base
    # https://companion.broadmail.de/display/DEMANUAL/getAllFlat+-+RecipientWebservice
    def all(list_id, *attribute_names)
      response = fetch_value(:get_all, recipientListId: list_id,
                                       attributeNames: [attribute_names])
      build_result_array attribute_names, response[:get_all_return].map { |res| res[:get_all_return] }
    end

    # https://companion.broadmail.de/display/DEMANUAL/remove+-+RecipientWebservice
    def remove(list_id:, email:)
      @email = email
      fetch(:remove, recipientListId: list_id,
                     recipientId: email)
    rescue => e
      if e.message =~ /Recipient does not exist for call/i
        raise OptivoApi::RecipientNotInList, e.message
      else
        raise
      end
    end

    # first removes the user if exits
    # then add it to the list
    def force_add(list_id:, email:, attribute_names:, attribute_values:)
      suppress(OptivoApi::RecipientNotInList) do
        @email = email
        remove(list_id: list_id, email: email)
      end
      add(list_id: list_id, email: email, attribute_names: attribute_names, attribute_values: attribute_values)
    end

    # https://companion.broadmail.de/display/DEMANUAL/add2+-+RecipientWebservice
    def add(list_id:, email:, attribute_names:, attribute_values:)
      @email = email
      parse_result fetch_value(:add2, recipientListId: list_id,
                                      optinProcessId: 0,
                                      recipientId: email,
                                      address: email,
                                      attributeNames:  [attribute_names],
                                      attributeValues: [attribute_values])
    end

    private

    attr_reader :email

    def error_message(code)
      {
        1 => "Invalid email-address",
        2 => "Receiver is on the unscriped list.",
        3 => "Receiver is on the blacklist.",
        4 => "Receiver has exceeded the Bounce-Limit.",
        5 => "Receiver is already on this list.",
        6 => "Receiver was filtered out.",
        7 => "Internal error."
      }[code]
    end

    def parse_result(result)
      default_msg = "#{error_message(result.to_i)} ErrorCode: #{result.to_i}. email: #{email}"
      case result.to_i
      when 0, 5
        true
      when 1
        OptivoApi.log(default_msg)
        raise OptivoApi::InvalidEmail, default_msg
      when 3
        OptivoApi.log(default_msg)
        raise OptivoApi::RecipientIsOnTheBlacklist, default_msg
      when 4
        OptivoApi.log(default_msg)
        raise OptivoApi::RecipientExceededBounceLimit, default_msg
      else
        OptivoApi.log(default_msg)
        raise OptivoApi::Error, default_msg
      end
    end
  end
end
