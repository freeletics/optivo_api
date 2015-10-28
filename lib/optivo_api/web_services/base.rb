module OptivoApi::WebServices
  class Base
    def webservice
      self.class.name.demodulize
    end

    def fetch(call_name, attributes = {})
      OptivoApi::Request.fetch!(webservice: webservice, call_name: call_name, attributes: attributes)
    end

    def fetch_value(call_name, attributes = {})
      fetch(call_name, attributes).value
    end

    private

    def build_result_array(keys, values)
      values.map do |v|
        Array(v).map! { |val| (val.is_a?(Hash) && val.key?(:"@xsi:type")) ? nil : val }
        Hash[Array(keys).zip(Array(v))]
      end
    end
  end
end
