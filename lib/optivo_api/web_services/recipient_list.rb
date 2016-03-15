module OptivoApi::WebServices
  # https://companion.broadmail.de/display/DEMANUAL/RecipientListWebservice
  class RecipientList < Base
    def count(include_test_lists: false)
      fetch_value(:get_count, includeTestLists: include_test_lists)
    end

    def ids
      Array(fetch_value(:get_all_ids))
    end

    def attribute_names(list_id, locale: :de)
      fetch_value(:get_attribute_names, recipientListId: list_id, locale: locale)
        .try(:fetch, :get_attribute_names_return)
    end

    def name(list_id)
      fetch_value(:get_name, recipientListId: list_id)
    end

    def all
      {}.tap do |result|
        ids.each { |id| result[id] = name(id) }
      end
    end
  end
end
