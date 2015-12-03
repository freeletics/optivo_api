require "spec_helper"

RSpec.describe OptivoApi do
  it "has a version number" do
    expect(OptivoApi::VERSION).not_to be nil
  end
end
