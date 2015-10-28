require 'spec_helper'

RSpec.describe OptivoApi::WebServices::Mailing do
  let(:mailing) { OptivoApi::WebServices::Mailing.new }

  describe '#ids' do
    it 'gets valid value' do
      VCR.use_cassette('mailing_ids') do
        expect(mailing.ids).to eq(%w(112769986317 112770005572))
      end
    end
  end

  describe '#name' do
    it 'gets valid value' do
      VCR.use_cassette('mailing_name') do
        expect(mailing.name(112_770_005_572)).to eq('Test-Welcome-Mail')
      end
    end
  end

  describe '#all' do
    it 'gets valid value' do
      VCR.use_cassette('mailing_all') do
        expect(mailing.all).to eq({"112769986317" => "Test-Welcome-Mail Michael", "112770005572" => "Test-Welcome-Mail"})
      end
    end
  end

  describe '#send_mail' do
    it 'gets valid value' do
      VCR.use_cassette('mailing_send_mail') do
        expect(mailing.send_mail(list_id: 108_713_280_263, mailing_id: 112_769_986_317, email: 'tester1@test.com')).to be_truthy
      end
    end

    it 'raises an error with invalid email' do
      VCR.use_cassette('mailing_send_wrong_mail') do
        expect do
          mailing.send_mail(list_id: 108_713_280_263, mailing_id: 112_769_986_317, email: 'some_where@overtherainbow.com')
        end.to raise_error OptivoApi::RecipientNotFound
      end
    end

    it 'raises an error with invalid list' do
      VCR.use_cassette('mailing_send_wrong_list_id') do
        expect do
          mailing.send_mail(list_id: 666 , mailing_id: 112_769_986_317, email: 'tester1@test.com')
        end.to raise_error "Invalid list. ErrorCode: 4"
      end
    end
  end
end
