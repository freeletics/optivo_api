module OptivoApi::WebServices
  # https://companion.broadmail.de/display/DEMANUAL/MailingWebservice
  class Mailing < Base
    def ids(mailing_type: :event)
      # mailingType (regular, event, confirmation)
      Array(fetch_value(:get_ids, mailingType: mailing_type))
    end

    def name(mailing_id)
      fetch_value(:get_name, mailingId: mailing_id)
    end

    # https://companion.broadmail.de/display/DEMANUAL/sendMail+-+MailingWebservice
    def send_mail(list_id:, mailing_id:, recipient_id:)
      @recipient_id = recipient_id
      parse_result fetch_value(:send_mail, mailingId: mailing_id, recipientListId: list_id, recipientId: recipient_id)
    end

    # Returns a hash with list_id => list_name
    def all(mailing_type: :event)
      {}.tap do |result|
        ids(mailing_type: mailing_type).each do |id|
          result[id] = name(id)
        end
      end
    end

    private

    attr_reader :recipient_id

    def error_message(code)
      {
        1 => "Recipient is blocked.",
        2 => "Recipient is on the unscriped-list.",
        3 => "Recipient was not found.",
        4 => "Invalid list.",
        5 => "Recipient does not fit into the targeting criteria.",
        6 => "Recipient has created too many bounces."
      }[code]
    end

    def parse_result(result)
      default_msg = "#{error_message(result.to_i)} ErrorCode: #{result}. recipient_id: #{recipient_id}"
      case result.to_i
      when 0
        true
      when 3
        OptivoApi.log(default_msg)
        raise OptivoApi::RecipientNotFound, default_msg
      else
        OptivoApi.log(default_msg)
        raise OptivoApi::Error, default_msg
      end
    end
  end
end
