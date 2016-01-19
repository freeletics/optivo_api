require "spec_helper"

RSpec.describe OptivoApi::WebServices::Recipient do
  let(:recipient) { OptivoApi::WebServices::Recipient.new }

  describe "#all" do
    it "gets valid value" do
      VCR.use_cassette("recipient_get_all") do
        expect(recipient.all("120199092218", :email, :last_name)).to eq(
          [{email: "athletes@freeletics.com", last_name: "Official"},
           {email: "nocoach@test.com", last_name: "test"},
           {email: "coach@test.com", last_name: "test"}]
        )
      end
    end
  end

  describe "#remove" do
    it "gets valid value" do
      VCR.use_cassette("recipient_remove") do
        expect(recipient.remove(list_id: "120199092218", recipient_id: 2)).to be_success
      end
    end

    it "not existing user raises an exception" do
      VCR.use_cassette("recipient_remove_not_exits") do
        expect do
          expect(recipient.remove(list_id: "120199092218", recipient_id: 666)).to be_success
        end.to raise_error(OptivoApi::RecipientNotInList)
      end
    end
  end

  describe "#force_remove" do
    it "gets valid value" do
      VCR.use_cassette("recipient_remove") do
        expect(recipient.force_remove(list_id: "120199092218", recipient_id: 2)).to be_success
      end
    end

    it "not existing user raises an exception" do
      VCR.use_cassette("recipient_remove_not_exits") do
        expect do
          expect(recipient.force_remove(list_id: "120199092218", recipient_id: 666))
        end.to_not raise_error
      end
    end
  end

  describe "#add" do
    it "gets valid value" do
      VCR.use_cassette("recipient_add") do
        expect(recipient.add(
                 list_id: "120199092218",
                 recipient_id: 88,
                 email: "tester@test.com",
                 attribute_names: ["last_name"],
                 attribute_values: ["tester1"])).to be_truthy
      end
    end

    it "blacklisted email raises an exception" do
      allow(recipient).to receive(:fetch_value).and_return(3)
      expect do
        recipient.add(
          list_id: "120199092218",
          recipient_id: 333,
          email: "blacklisted@test.com",
          attribute_names: ["last_name"],
          attribute_values: ["tester1"])
      end.to raise_error(OptivoApi::RecipientIsOnTheBlacklist,
        /Receiver is on the blacklist. ErrorCode: 3 recipient_id: 333 email: blacklisted@test.com/)
    end

    it "bounced email raises an exception" do
      allow(recipient).to receive(:fetch_value).and_return(4)
      expect do
        recipient.add(
          list_id: "120199092218",
          recipient_id: 333,
          email: "bounced@test.com",
          attribute_names: ["last_name"],
          attribute_values: ["tester1"])
      end.to raise_error(OptivoApi::RecipientExceededBounceLimit,
        /Receiver has exceeded the Bounce-Limit. ErrorCode: 4 recipient_id: 333 email: bounced@test.com/)
    end

    it "invalid email raises an exception" do
      VCR.use_cassette("recipient_add_invalid_email") do
        expect do
          recipient.add(
            list_id: "120199092218",
            recipient_id: 333,
            email: "invalid",
            attribute_names: ["last_name"],
            attribute_values: ["tester1"])
        end.to raise_error(OptivoApi::InvalidEmail,
          /Invalid email-address ErrorCode: 1 recipient_id: 333 email: invalid/)
      end
    end
  end

  describe "#force_add" do
    it "gets valid value" do
      VCR.use_cassette("receipient_force_add") do
        expect(recipient.force_add(
                 list_id: "120199092218",
                 recipient_id: 555,
                 email: "tester1@test.com",
                 attribute_names: ["last_name"],
                 attribute_values: ["tester1"])).to be_truthy
      end
    end

    it "calls the valid methods in the right order" do
      expect(recipient).to receive(:add).with(
        list_id: "120199092218",
        email: "tester1@test.com",
        recipient_id: 777,
        attribute_names: ["last_name"],
        attribute_values: ["tester1"]).and_raise OptivoApi::RecipientIsAlreadyOnThisList
      expect(recipient).to receive(:remove).with(
        list_id: "120199092218", recipient_id: 777).ordered

      expect(recipient).to receive(:add).with(
        list_id: "120199092218",
        recipient_id: 777,
        email: "tester1@test.com",
        attribute_names: ["last_name"],
        attribute_values: ["tester1"]).ordered

      VCR.use_cassette("recipient_add") do
        recipient.force_add(
          list_id: "120199092218",
          recipient_id: 777,
          email: "tester1@test.com",
          attribute_names: ["last_name"],
          attribute_values: ["tester1"])
      end
    end

    it "ignores no other exception" do
      expect do
        allow(recipient).to receive(:add).and_raise "too much information"

        recipient.force_add(
          list_id: "120199092218",
          recipient_id: 777,
          email: "tester1@test.com",
          attribute_names: ["last_name"],
          attribute_values: ["tester1"])
      end.to raise_error("too much information")
    end
  end

  describe "#update" do
    it "a user" do
      VCR.use_cassette("receipient_update_an_existing_user") do
        expect(recipient.update(
                 list_id: "120199092218",
                 recipient_id: 1,
                 attribute_names: ["last_name"],
                 attribute_values: ["tester123"]))
      end
    end

    it "a none existing user" do
      VCR.use_cassette("receipient_update_a_none_existing_user") do
        expect do
          recipient.update(
            list_id: "120199092218",
            recipient_id: 12_345,
            attribute_names: ["last_name"],
            attribute_values: ["tester123"])
        end.to raise_error(OptivoApi::RecipientNotInList)
      end
    end
  end

  describe "#update_or_insert" do
    it "update an existing user" do
      VCR.use_cassette("update_or_insert_an_existing_user") do
        expect(recipient.update_or_insert(
                 list_id: "120199092218",
                 recipient_id: 1,
                 email: "tester1123xyuz@test.com",
                 attribute_names: ["last_name"],
                 attribute_values: ["tester_name1"]))
      end
    end

    it "add an user if not exists" do
      allow(recipient).to receive(:update).and_raise OptivoApi::RecipientNotInList
      expect(recipient).to receive(:add).with(
        list_id: "120199092218",
        recipient_id: 666,
        email: "tester1@test.com",
        attribute_names: ["last_name"],
        attribute_values: ["tester_name1"])
      expect(recipient.update_or_insert(
               list_id: "120199092218",
               recipient_id: 666,
               email: "tester1@test.com",
               attribute_names: ["last_name"],
               attribute_values: ["tester_name1"]))
    end

    it "a none existing user" do
      VCR.use_cassette("update_or_insert_a_none_existing_user") do
        recipient.update_or_insert(
          list_id: "120199092218",
          recipient_id: 321,
          email: "Unknown@test.com",
          attribute_names: ["last_name"],
          attribute_values: ["Unknown"])
      end
    end
  end
end
