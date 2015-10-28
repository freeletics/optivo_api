require "spec_helper"

RSpec.describe OptivoApi::WebServices::RecipientList do
  let(:list) { OptivoApi::WebServices::RecipientList.new }
  describe '#count' do
    it "gets valid value" do
      VCR.use_cassette("recipient_list_count") do
        expect(list.count).to eq("4")
      end
    end
  end

  describe '#all_ids' do
    it "gets valid value" do
      VCR.use_cassette("recipient_list_all_ids") do
        expect(list.all_ids).to eq(%w(108713280294 108713280297 108713280263 108713280303 108713280264))
      end
    end
  end

  describe '#all' do
    it "gets valid value" do
      VCR.use_cassette("recipient_list_all") do
        expect(list.all).to eq(
          "108713280303" => "first_trainining",
          "108713280297" => "welcome_mail",
          "108713280264" => "newsletter_subscribers",
          "108713280294" => "referral_program",
          "108713280263" => "Testliste"
        )
      end
    end
  end

  describe '#attribute_names' do
    it "gets valid value" do
      VCR.use_cassette("recipient_list_attribute_names") do
        expect(list.attribute_names(108_713_280_297)).to eq(
          ["user_id",
           "email",
           "first_name",
           "last_name",
           "gender",
           "locale",
           "onboarding_fitness_level",
           "onboarding_first_workout",
           "onboarding_workout_link",
           "registration_source",
           "registration_country",
           "Erstellt am",
           "Geändert am",
           "Opt-in-Quelle",
           "Opt-in-Datum"]
        )
      end
    end
  end

  describe '#name' do
    it "gets valid value" do
      VCR.use_cassette("recipient_list_name") do
        expect(list.name("108713280297")).to eq("welcome_mail")
      end
    end
  end
end
