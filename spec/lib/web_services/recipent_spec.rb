require "spec_helper"

RSpec.describe OptivoApi::WebServices::Recipient do
  let(:receipient) { OptivoApi::WebServices::Recipient.new }

  describe '#all' do
    it "gets valid value" do
      VCR.use_cassette("recipient_get_all") do
        expect(receipient.all("108713280263", :email, :last_name)).to eq(
          [{email: "amelie@blah.com", last_name: nil},
           {email: "blah@blah.com", last_name: "blah"},
           {email: "michael@blah.de", last_name: "tester"},
           {email: "nina@blah.com", last_name: nil},
           {email: "steffi@blah.com", last_name: nil},
           {email: "test@blah.de", last_name: nil},
           {email: "test@blah2.de", last_name: "tester"},
           {email: "tester1@test.com", last_name: nil}]
        )
      end
    end
  end

  describe '#remove' do
    it "gets valid value" do
      VCR.use_cassette("recipient_remove") do
        expect(receipient.remove(list_id: "108713280263", email: "tester1@test.com")).to be_success
      end
    end

    it "not existing user raises an exception" do
      VCR.use_cassette("recipient_remove_not_exits") do
        expect do
          expect(receipient.remove(list_id: "108713280263", email: "superhero@test.com")).to be_success
        end.to raise_error(OptivoApi::RecipientNotInList)
      end
    end
  end

  describe '#add' do
    it "gets valid value" do
      VCR.use_cassette("recipient_add") do
        expect(receipient.add(
                 list_id: "108713280263",
                 email: "tester1@test.com",
                 attribute_names: ["last_name"],
                 attribute_values: ["tester1"])).to be_truthy
      end
    end

    it "blacklisted email raises an exception" do
      expect do
        allow(receipient).to receive(:fetch_value).and_return(3)
        receipient.add(
          list_id: "108713280263",
          email: "member@blacklisted.com",
          attribute_names: ["last_name"],
          attribute_values: ["tester1"])
      end.to raise_error(OptivoApi::RecipientIsOnTheBlacklist,
        /Receiver is on the blacklist. ErrorCode: 3. email: member@blacklisted.com/)
    end

    it "bounced email raises an exception" do
      expect do
        allow(receipient).to receive(:fetch_value).and_return(4)
        receipient.add(
          list_id: "108713280263",
          email: "member@bounced.com",
          attribute_names: ["last_name"],
          attribute_values: ["tester1"])
      end.to raise_error(OptivoApi::RecipientExceededBounceLimit,
        /Receiver has exceeded the Bounce-Limit. ErrorCode: 4. email: member@bounced.com/)
    end

    it "invalid email raises an exception" do
      VCR.use_cassette("recipient_add_invalid_email") do
        expect do
          expect(receipient.add(
                   list_id: "108713280263",
                   email: "invalid",
                   attribute_names: ["last_name"],
                   attribute_values: ["tester1"]))
        end.to raise_error(OptivoApi::InvalidEmail,
          /Invalid email-address ErrorCode: 1. email: invalid/)
      end
    end
  end
end
