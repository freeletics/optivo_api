module OptivoApi::WebServices
  # https://world.episerver.com/documentation/developer-guides/campaign/SOAP-API/recipientwebservice/
  class Recipient < Base
    def all(list_id, *attribute_names)
      response = fetch_value(:get_all_flat, recipientListId: list_id,
                                            attributeNames: [attribute_names])

      result_to_hash convert_values(response[:get_all_flat_return]), attribute_names
    end

    def remove(list_id:, recipient_id:)
      @recipient_id = recipient_id
      rescue_recipient_not_in_list(recipient_id) do
        fetch(:remove, recipientListId: list_id,
                       recipientId: recipient_id)
      end
    end

    # suppress the exception when user not exits
    def force_remove(list_id:, recipient_id:)
      @recipient_id = recipient_id
      remove(list_id: list_id, recipient_id: recipient_id)
    rescue OptivoApi::RecipientNotInList # rubocop:disable Lint/HandleExceptions
    end

    # Returns a Hash with attribute => value of recipient
    def get(list_id:, recipient_id:, attribute_names: [])
      attribute_names = RecipientList.new.attribute_names(list_id) if attribute_names.empty?

      rescue_recipient_not_in_list(recipient_id) do
        result = get_attributes(
          list_id: list_id,
          recipient_id: recipient_id,
          attribute_names: attribute_names)

        return {} if attribute_names.empty?

        attribute_names.zip(result).to_h
      end
    end

    def get_attributes(list_id:, recipient_id:, attribute_names:)
      convert_values fetch_value(:get_attributes,
        recipient_list_id: list_id,
        recipient_id: recipient_id,
        attribute_names: [attribute_names])&.fetch(:get_attributes_return)
    end

    # first removes the user if exits
    # then add it to the list
    def force_add(list_id:, recipient_id:, email:, attribute_names:, attribute_values:)
      @recipient_id = recipient_id
      @email = email
      add(list_id: list_id,
          recipient_id: recipient_id,
          email: email,
          attribute_names: attribute_names,
          attribute_values: attribute_values)
    rescue OptivoApi::RecipientIsAlreadyOnThisList
      remove(list_id: list_id, recipient_id: recipient_id)
      safe_add(list_id: list_id,
               recipient_id: recipient_id,
               email: email,
               attribute_names: attribute_names,
               attribute_values: attribute_values)
    end

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

    def update(list_id:, recipient_id:, attribute_names:, attribute_values:)
      @recipient_id = recipient_id
      rescue_recipient_not_in_list(recipient_id) do
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

    # Updates many recipients with given attributes
    #
    # attributes - array of hashes with name, value pair - keys must contain the same set for each object
    #
    # Examples
    #
    #   bulk_update(
    #     list_id: 1,
    #     recipient_ids: [1, 2],
    #     attributes: [{"locale" => "en", "first_name" => "John"}, {"locale" => "de", "first_name" => "Jane"}]
    #   )
    def bulk_update(list_id:, recipient_ids:, attributes:)
      attribute_names = attributes.first.keys.sort
      if attributes.any? { |recipient| recipient.keys.sort != attribute_names }
        raise ArgumentError, "Each object must contain the same set of keys"
      end

      attribute_values = attributes.flat_map do |recipient|
        attribute_names.map { |name| recipient[name] }
      end

      fetch_value(
        :set_attributes_in_batch_flat,
        recipientListId: list_id,
        recipientIds: [recipient_ids],
        attributeNames: [attribute_names],
        flatAttributeValues: [attribute_values]
      )
    rescue OptivoApi::UnknownError => error
      if (match = error.message.match(/Recipients (.*) do not exist for call/))
        raise OptivoApi::RecipientNotInList.new(error.message, match[1].split(","))
      else
        raise
      end
    end

    private

    attr_reader :recipient_id, :email

    def safe_add(list_id:, recipient_id:, email:, attribute_names:, attribute_values:)
      add(list_id: list_id,
          recipient_id: recipient_id,
          email: email,
          attribute_names: attribute_names,
          attribute_values: attribute_values)
    rescue OptivoApi::RecipientIsAlreadyOnThisList # rubocop:disable Lint/HandleExceptions
    end

    def rescue_recipient_not_in_list(recipient_id)
      yield
    rescue OptivoApi::RecipientIsAlreadyOnThisList # rubocop:disable Lint/HandleExceptions
    rescue StandardError => e
      if e.message.match?(/Recipient does not exist[s]? for call/i)
        raise OptivoApi::RecipientNotInList.new(e.message, recipient_id.to_s)
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
      default_msg = "#{error_message(result.to_i)} ErrorCode: #{result.to_i} "\
        "recipient_id: #{recipient_id} #{'email: ' + email if email}"
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
