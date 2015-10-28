require "spec_helper"

RSpec.describe OptivoApi::Request do
  let(:request) { OptivoApi::Request.new call_name: "get_all", webservice: "Receipient", attributes: {a: "b"} }

  describe '#auth?' do
    it "true by defautl" do
      expect(request).to be_auth
    end

    it "false when set" do
      request = OptivoApi::Request.new call_name: "get_all", webservice: "Receipient", auth: false
      expect(request).not_to be_auth
    end
  end

  describe '#optivo_url' do
    it "set the valid url" do
      expect(request.optivo_url).to eq("https://api.broadmail.de/soap11/RpcReceipient?WSDL")
    end
  end

  describe '#fetch!' do
    it "calls the client with request" do
      request
      mock_client = double(OptivoApi::Client)
      allow(OptivoApi::Client).to receive(:new).and_return mock_client
      allow(mock_client).to receive(:call).with(request)
      request.fetch!
    end
  end
end
