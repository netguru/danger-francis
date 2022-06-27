# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)
require_relative "../lib/francis/clients/code_climate_client"
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

  it "two" do
    client = CodeClimateClient.new
    client.repo_id = "fixture_repo_id"
    client.token = "fixture_token"
    client.branch = "master"
    builds_response = Typhoeus::Response.new(code: 200, body: File.read("spec/fixtures/codeclimate_builds.json"))
    snapshots_reponse = Typhoeus::Response.new(code: 200, body: File.read("spec/fixtures/codeclimate_snapshots.json"))
    Typhoeus.stub(/snapshots/).and_return(snapshots_reponse)
    count = 0
    Typhoeus.stub(/builds/) do |request|
      if count == 0
        count += 1
        Typhoeus::Response.new(code: 200)
      else
        builds_response
      end
    end
    result = client.status
    expect(result[:rating]).to eq("C")
    expect(result[:issues]).to eq(6)
    expect(result[:debt_value]).to eq(10.270369550217175)
    expect(result[:refactoring_time]).to eq(262.0)
  end
end
