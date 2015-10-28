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
      fetch(:remove, recipientListId: list_id,
                     recipientId: email)
    end

    # https://companion.broadmail.de/display/DEMANUAL/add2+-+RecipientWebservice
    def add(list_id:, email:, attribute_names:, attribute_values:)
      parse_result fetch_value(:add2, recipientListId: list_id,
                                      optinProcessId: 0,
                                      recipientId: email,
                                      address: email,
                                      attributeNames:  [attribute_names],
                                      attributeValues: [attribute_values])
    end

    private

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
      case result.to_i
      when 0, 5
        true
      when 1
        raise OptivoApi::InvalidEmail, "#{error_message(result.to_i)} ErrorCode: #{result.to_i}"
      else
        raise OptivoApi::Error, "#{error_message(result.to_i)} ErrorCode: #{result.to_i}"
      end
   end
  end
end
