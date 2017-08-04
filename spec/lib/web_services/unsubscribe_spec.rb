require "spec_helper"

RSpec.describe OptivoApi::WebServices::Unsubscribe do
  let(:unsubscribe) { OptivoApi::WebServices::Unsubscribe.new }
  describe "#add" do
    it "gets valid value" do
      VCR.use_cassette("unsubscribe_add") do
        expect(unsubscribe.add(recipient_id: 1)).to be_truthy
      end
    end
  end

  describe "#contains" do
    it "gets valid value" do
      VCR.use_cassette("unsubscribe_contains") do
        expect(unsubscribe.contains(recipient_id: 1)).to eq(true)
      end
    end
  end

  describe "#remove" do
    it "gets valid value" do
      VCR.use_cassette("unsubscribe_remove") do
        expect(unsubscribe.remove(recipient_id: 1)).to be_truthy
      end
    end
  end
end
