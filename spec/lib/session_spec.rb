require "spec_helper"

RSpec.describe OptivoApi::Session do
  let(:session) { OptivoApi::Session.new }

  describe "#login" do
    it "return a session_id" do
      VCR.use_cassette("session_login") do
        result = session.login
        expect(result).to eq("33c4296db6972a38")
        expect(result.class).to eq(String)
      end
    end

    it "raises AuthenticationError with invalid credentials" do
      VCR.use_cassette("session_login_bad_crendials") do
        expect do
          expect(session.login)
        end.to raise_error(OptivoApi::AuthenticationError)
      end
    end
  end

  describe "#logout" do
    it "not raises an error" do
      VCR.use_cassette("session_logout") do
        session.login
        expect(session.logout).to be_truthy
      end
    end
  end
end
