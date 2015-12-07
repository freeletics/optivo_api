require "spec_helper"

RSpec.describe OptivoApi::WebServices::Recipient do
  let(:receipient) { OptivoApi::WebServices::Recipient.new }

  describe '#all' do
    it "gets valid value" do
      VCR.use_cassette("recipient_get_all") do
        expect(receipient.all("108713280263", :email, :last_name)).to include(
          {email: "nina+01@freeletics.com", last_name: "Test"},
          {email: "nina+02@freeletics.com", last_name: "Muster"},
          {email: "nina+03@freeletics.com", last_name: "Suppe"},
          email: "nina+04@freeletics.com", last_name: "Tänzer"
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

  describe '#force_add' do
    it "gets valid value" do
      VCR.use_cassette("force_add") do
        expect(receipient.force_add(
                 list_id: "108713280263",
                 email: "tester1@test.com",
                 attribute_names: ["last_name"],
                 attribute_values: ["tester1"])).to be_truthy
      end
    end

    it "calls the valid methods in the right order" do
      expect(receipient).to receive(:add).with(
        list_id: "108713280263",
        email: "tester1@test.com",
        attribute_names: ["last_name"],
        attribute_values: ["tester1"]).and_raise OptivoApi::RecipientIsAlreadyOnThisList
      expect(receipient).to receive(:remove).with(list_id: "108713280263", email: "tester1@test.com").ordered

      expect(receipient).to receive(:add).with(
        list_id: "108713280263",
        email: "tester1@test.com",
        attribute_names: ["last_name"],
        attribute_values: ["tester1"]).ordered

      VCR.use_cassette("recipient_add") do
        receipient.force_add(
          list_id: "108713280263",
          email: "tester1@test.com",
          attribute_names: ["last_name"],
          attribute_values: ["tester1"])
      end
    end

    it "ignores no other exception" do
      expect do
        allow(receipient).to receive(:add).and_raise "too much information"

        receipient.force_add(
          list_id: "108713280263",
          email: "tester1@test.com",
          attribute_names: ["last_name"],
          attribute_values: ["tester1"])
      end.to raise_error("too much information")
    end
  end

  describe "#update" do
    it "a user" do
      VCR.use_cassette("update_an_existing_user") do
        expect(receipient.update(
                 list_id: "108713280263",
                 email: "tester1@test.com",
                 attribute_names: ["last_name"],
                 attribute_values: ["tester123"]))
      end
    end

    it "a none existing user" do
      VCR.use_cassette("update_a_none_existing_user") do
        expect do
          receipient.update(
            list_id: "108713280263",
            email: "Unknown@test.com",
            attribute_names: ["last_name"],
            attribute_values: ["tester123"])
        end.to raise_error(OptivoApi::RecipientNotInList)
      end
    end
  end

  describe "#update_or_insert" do
    it "update an existing user" do
      VCR.use_cassette("update_or_insert_an_existing_user") do
        expect(receipient.update_or_insert(
                 list_id: "108713280263",
                 email: "tester1@test.com",
                 attribute_names: ["last_name"],
                 attribute_values: ["tester_name1"]))
      end
    end

    it "add an user if not exists" do
      allow(receipient).to receive(:update).and_raise OptivoApi::RecipientNotInList
      expect(receipient).to receive(:add).with(
        list_id: "108713280263",
        email: "tester1@test.com",
        attribute_names: ["last_name"],
        attribute_values: ["tester_name1"])
      expect(receipient.update_or_insert(
               list_id: "108713280263",
               email: "tester1@test.com",
               attribute_names: ["last_name"],
               attribute_values: ["tester_name1"]))
    end

    it "a none existing user" do
      VCR.use_cassette("update_or_insert_a_none_existing_user") do
        receipient.update_or_insert(
          list_id: "108713280263",
          email: "Unknown@test.com",
          attribute_names: ["last_name"],
          attribute_values: ["Unknown"])
      end
    end
  end
end
