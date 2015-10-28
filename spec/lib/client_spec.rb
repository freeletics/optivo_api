require "spec_helper"

RSpec.describe OptivoApi::Client do
  let(:request) { OptivoApi::Request.new call_name: "get_all", webservice: "Receipient", attributes: {a: "b"} }

  describe '#call' do
    let(:savon_client) { double(Savon::Client).as_null_object }
    let(:session) { double(OptivoApi::Session, login: 123).as_null_object }
    before { allow(Savon::Client).to receive(:new).and_return savon_client }
    before { allow(OptivoApi::Session).to receive(:new).and_return session }

    it "calls the savon_client" do
      allow(savon_client).to receive(:call).with("get_all",
        message: {:a => "b", "sessionId" => 123}).and_return(savon_client)
      OptivoApi::Client.new.call request
    end

    it "should retry it 3 times by InvalidSession" do
      allow(savon_client).to receive(:call).exactly(4).times.and_raise OptivoApi::InvalidSession
      allow(OptivoApi).to receive(:log).with("use sessionId: 123 for get_all")
      allow(OptivoApi).to receive(:log).with("refetch_session_id for 1. time")
      allow(OptivoApi).to receive(:log).with("refetch_session_id for 2. time")
      allow(OptivoApi).to receive(:log).with("refetch_session_id for 3. time")
      expect do
        OptivoApi::Client.new.call request
      end.to raise_error OptivoApi::InvalidSession
    end
  end

  describe "caching" do
    let(:cache) { BlackHoleStore.new }
    let(:client) { OptivoApi::Client.new }
    before { allow(client).to receive(:cache).and_return cache }

    it "has a cache" do
      expect(client.send(:cache?)).to be_truthy
    end

    it "fetches the session_id from the cache" do
      expect(cache).to receive(:fetch).with("optivo_api_session_id",
        expires_in: 10.minutes, force: false).and_return 666
      expect(client.send(:fetch_session_id)).to eq(666)
    end
  end
end
