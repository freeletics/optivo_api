module OptivoApi::WebServices
  class Base
    def webservice
      self.class.name.demodulize
    end

    def fetch(call_name, attributes = {})
      OptivoApi::Request.fetch!(
        webservice: webservice,
        call_name: call_name,
        attributes: attributes)
    end

    def fetch_value(call_name, attributes = {})
      fetch(call_name, attributes).try(:value)
    end

    private

    def convert_values(values)
      Array(values).map { |val| (val.is_a?(Hash) && val.key?(:"@xsi:type")) ? "" : val }
    end

    def result_to_hash(values, keys)
      [].tap do |result|
        values.each_slice(keys.size) do |slice|
          result << {}.tap do |hsh|
            (0..(keys.size - 1)).each do |i|
              hsh[keys[i]] = slice[i]
            end
          end
        end
      end
    end
  end
end
