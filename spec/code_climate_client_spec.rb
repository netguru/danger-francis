# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)
require_relative "../lib/francis/code_climate_client"
require_relative "mocks/codeclimate_mocks"

describe CodeClimateClient do
  before do
    Typhoeus::Expectation.clear
  end

  it "one" do
    client = CodeClimateClient.new
    client.repo_id = "fixture"
    setup_codeclimate_mocks

    result = client.status
    expect(result[:rating]).to eq("C")
    expect(result[:issues]).to eq(6)
    expect(result[:debt_value]).to eq(10.270369550217175)
    expect(result[:refactoring_time]).to eq(262.0)
  end
end
