require "spec_helper"

RSpec.describe OptivoApi::WebServices::Blacklist do
  let(:blacklist) { OptivoApi::WebServices::Blacklist.new }

  describe "#all" do
    it "gets recent blacklisted emails" do
      VCR.use_cassette("blacklist_all") do
        expect(blacklist.all).to eq(["wojtek-spam@test.com", "wojtek-spam-2@test.com"])
      end
    end
  end

  describe "#add" do
    it "adds email to blacklist" do
      VCR.use_cassette("blacklist_add") do
        blacklist.add(email: "wojtek-spam@test.com", reason: "test")
      end
    end
  end

  describe "#contains" do
    it "returns true when email exists on blacklist" do
      VCR.use_cassette("blacklist_contains-true") do
        expect(blacklist.contains(email: "wojtek-spam@test.com")).to be(true)
      end
    end

    it "returns false when email does not exist on blacklist" do
      VCR.use_cassette("blacklist_contains-false") do
        expect(blacklist.contains(email: "wojtek-non-existing@test.com")).to be(false)
      end
    end
  end

  describe "#remove" do
    it "removes email from blacklist" do
      VCR.use_cassette("blacklist_remove") do
        blacklist.remove(email: "wojtek-spam@test.com")
      end
    end
  end
end
