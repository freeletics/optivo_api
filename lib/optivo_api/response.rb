class OptivoApi::Response
  attr_accessor :document
  attr_reader :raw_response, :request

  def initialize(raw_response:, request:)
    @raw_response = raw_response
    @request      = request
    @document     = raw_response&.to_hash || {}
  end

  def value
    if document.key? :multi_ref
      document[:multi_ref]
    else
      document
        .fetch("#{@request.call_name}_response".to_sym, {})
        .fetch("#{@request.call_name}_return".to_sym, "")
    end
  end

  def success?
    raw_response.success?
  end

  def self.build(raw_response:, request:)
    new(raw_response: raw_response, request: request)
  end
end
