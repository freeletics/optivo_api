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

    def all_chuncked(start: 0, size: 1_000)
      results = fetch_value(:get_all_advanced_flat, pageStart: start, pageSize: size)[:get_all_advanced_flat_return]
      results.each_slice(5).map do |slice|
        {email: slice[2], reason: slice[3], blacklisted_at: slice[4]}
      end
    end
  end
end
