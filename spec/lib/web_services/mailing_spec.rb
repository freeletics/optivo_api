require "spec_helper"

RSpec.describe OptivoApi::WebServices::Mailing do
  let(:mailing) { OptivoApi::WebServices::Mailing.new }

  describe '#ids' do
    it "gets valid value" do
      VCR.use_cassette("mailing_ids") do
        expect(mailing.ids).to eq(%w(112769986317 112770005572))
      end
    end
  end

  describe '#name' do
    it "gets valid value" do
      VCR.use_cassette("mailing_name") do
        expect(mailing.name(112_770_005_572)).to eq("Test-Welcome-Mail")
      end
    end
  end

  describe '#all' do
    it "gets valid value" do
      VCR.use_cassette("mailing_all") do
        expect(mailing.all).to eq("112769986317" => "Test-Welcome-Mail Michael", "112770005572" => "Test-Welcome-Mail")
      end
    end
  end

  describe '#send_mail' do
    it "gets valid value" do
      VCR.use_cassette("mailing_send_mail") do
        expect(mailing
          .send_mail(
            list_id: 108_713_280_263,
            mailing_id: 112_769_986_317,
            recipient_id: 1)).to be_truthy
      end
    end

    it "sends mailing within different manadant" do
      config = {
        mandator_id: "113691715311",
        user: "system@test.com",
        password: "123456"
      }

      mailing = OptivoApi::WebServices::Mailing.new(config)
      VCR.use_cassette("mailing_send_mail_different_mandant") do
        expect(mailing
          .send_mail(
            list_id: 128_808_720_030,
            mailing_id: 118_835_160_305,
            recipient_id: 7_215_144
          )).to be_truthy
      end
    end

    it "raises an error with invalid email" do
      VCR.use_cassette("mailing_send_wrong_mail") do
        expect do
          mailing.send_mail(
            list_id: 108_713_280_263,
            mailing_id: 112_769_986_317,
            recipient_id: 123_456_789)
        end.to raise_error OptivoApi::RecipientNotFound
      end
    end

    it "raises an error with invalid list" do
      VCR.use_cassette("mailing_send_wrong_list_id") do
        expect do
          mailing.send_mail(list_id: 666, mailing_id: 112_769_986_317, recipient_id: 1)
        end.to raise_error(/Invalid list. ErrorCode: 4. recipient_id: 1/)
      end
    end
  end
end
