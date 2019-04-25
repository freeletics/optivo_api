module OptivoApi::WebServices
  # https://world.episerver.com/documentation/developer-guides/campaign/SOAP-API/blacklistwebservice/
  class Blacklist < Base
    def all
      fetch_value(:get_all_entries)[:get_all_entries_return]
    end

    def add(email:, reason: nil)
      fetch_value(:add, entry: email, reason: reason)
    end

    def contains(email:)
      fetch_value(:contains, entry: email)
    end

    def remove(email:)
      fetch_value(:remove, entry: email)
    end
  end
end
