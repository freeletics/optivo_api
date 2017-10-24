module OptivoApi::WebServices
  # https://companion.broadmail.de/display/DEMANUAL/UnsubscribeWebservice
  class Unsubscribe < Base
    # https://companion.broadmail.de/display/DEMANUAL/remove+-+UnsubscribeWebservice
    def remove(recipient_id:)
      fetch_value(:remove, recipientId: recipient_id)
    rescue StandardError => e
      if e.message =~ /No unsubscribe found/i
        raise OptivoApi::NoUnsubscribeFound, e.message
      else
        raise
      end
    end

    # https://companion.broadmail.de/display/DEMANUAL/removeAll+-+UnsubscribeWebservice
    def remove_all(recipient_ids:)
      fetch_value(:remove_all, recipientId: recipient_id, recipientIds: [recipient_ids])
    end

    # https://companion.broadmail.de/display/DEMANUAL/add+-+UnsubscribeWebservice
    def add(recipient_id:, list_id: 0)
      fetch_value(:add, recipientListId: list_id,
                        recipientId: recipient_id)
    end

    # https://companion.broadmail.de/display/DEMANUAL/contains+-+UnsubscribeWebservice
    def contains(recipient_id:)
      fetch_value(:contains, recipientId: recipient_id)
    end

    # https://companion.broadmail.de/display/DEMANUAL/getCount+-+UnsubscribeWebservice
    def count
      fetch_value(:get_count).to_i
    end
  end
end
