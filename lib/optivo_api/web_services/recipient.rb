module OptivoApi::WebServices
  # https://companion.broadmail.de/display/DEMANUAL/RecipientWebservice
  class Recipient < Base
    # https://companion.broadmail.de/display/DEMANUAL/getAllFlat+-+RecipientWebservice
    def all(list_id, *attribute_names)
      response = fetch_value(:get_all_flat, recipientListId: list_id,
                                            attributeNames: [attribute_names])

      result_to_hash convert_values(response[:get_all_flat_return]), attribute_names
    end

    # https://companion.broadmail.de/display/DEMANUAL/remove+-+RecipientWebservice
    def remove(list_id:, recipient_id:)
      @recipient_id = recipient_id
      rescue_recipient_not_in_list do
        fetch(:remove, recipientListId: list_id,
                       recipientId: recipient_id)
      end
    end

    # suppress the exception when user not exits
    def force_remove(list_id:, recipient_id:)
      @recipient_id = recipient_id
      suppress(OptivoApi::RecipientNotInList) do
        remove(list_id: list_id, recipient_id: recipient_id)
      end
    end

    # first removes the user if exits
    # then add it to the list
    def force_add(list_id:, recipient_id:, email:, attribute_names:, attribute_values:)
      @recipient_id = recipient_id
      @email = email
      add(list_id: list_id, recipient_id: recipient_id, email: email, attribute_names: attribute_names, attribute_values: attribute_values)
    rescue OptivoApi::RecipientIsAlreadyOnThisList
      remove(list_id: list_id, recipient_id: recipient_id)
      safe_add(list_id: list_id, recipient_id: recipient_id, email: email, attribute_names: attribute_names, attribute_values: attribute_values)
    end

    # https://companion.broadmail.de/display/DEMANUAL/add2+-+RecipientWebservice
    def add(list_id:, recipient_id:, email:, attribute_names:, attribute_values:)
      @recipient_id = recipient_id
      @email = email
      parse_result fetch_value(:add2, recipientListId: list_id,
                                      optinProcessId: 0,
                                      recipientId: recipient_id,
                                      address: email,
                                      attributeNames:  [attribute_names],
                                      attributeValues: [attribute_values])
    end

    # https://companion.broadmail.de/display/DEMANUAL/setAttributes+-+RecipientWebservice
    def update(list_id:, recipient_id:, attribute_names:, attribute_values:)
      @recipient_id = recipient_id
      rescue_recipient_not_in_list do
        parse_result fetch_value(:set_attributes,
          recipientListId: list_id,
          recipientId: recipient_id,
          attributeNames:  [attribute_names],
          attributeValues: [attribute_values])
      end
    end

    # updates an existing user or insert a new one if not exits
    def update_or_insert(list_id:, recipient_id:, email:, attribute_names:, attribute_values:)
      update(
        list_id: list_id,
        recipient_id: recipient_id,
        attribute_names: attribute_names,
        attribute_values: attribute_values)
    rescue OptivoApi::RecipientNotInList
      safe_add(
       list_id: list_id,
       recipient_id: recipient_id,
       email: email,
       attribute_names: attribute_names,
       attribute_values: attribute_values)
    end

    private

    attr_reader :recipient_id, :email

    def safe_add(list_id:, recipient_id:, email:, attribute_names:, attribute_values:)
      suppress(OptivoApi::RecipientIsAlreadyOnThisList) do
        add(list_id: list_id, recipient_id: recipient_id, email: email,
          attribute_names: attribute_names, attribute_values: attribute_values)
      end
    end

    def rescue_recipient_not_in_list
      suppress(OptivoApi::RecipientIsAlreadyOnThisList) do
        yield
      end
    rescue => e
      if e.message =~ /Recipient does not exist[s]? for call/i
        raise OptivoApi::RecipientNotInList, e.message
      else
        raise
      end
    end

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
      default_msg = "#{error_message(result.to_i)} ErrorCode: #{result.to_i} recipient_id: #{recipient_id} #{'email: ' + email if email}"
      case result.to_i
      when 0
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
      when 5
        OptivoApi.log(default_msg)
        raise OptivoApi::RecipientIsAlreadyOnThisList, default_msg
      else
        OptivoApi.log(default_msg)
        raise OptivoApi::Error, default_msg
      end
    end
  end
end
