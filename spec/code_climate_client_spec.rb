# frozen_string_literal: true

require File.expand_path('../spec_helper', __FILE__)
require_relative '../lib/francis/code_climate_client'

describe CodeClimateClient do

  it 'one' do
    client = CodeClimateClient.new
    client.repo_id = "fixture"
    builds_response = Typhoeus::Response.new(code: 200, body: File.read('spec/fixtures/codeclimate_builds.json'))
    snapshots_reponse = Typhoeus::Response.new(code: 200, body: File.read('spec/fixtures/codeclimate_snapshots.json'))
    Typhoeus.stub(
      'https://api.codeclimate.com/v1/repos/fixture/builds?filter[state]=complete&filter[local_ref]=refs/heads/master'
    ).and_return(builds_response)
    Typhoeus.stub(
      'https://api.codeclimate.com/v1/repos/fixture/snapshots/fixture_id'
    ).and_return(snapshots_reponse)

    result = client.status
    expect(result[:rating]).to eq("C")
    expect(result[:issues]).to eq(6)
    expect(result[:debt_value]).to eq(10.270369550217175)
    expect(result[:refactoring_time]).to eq(262.0)

  end
end
