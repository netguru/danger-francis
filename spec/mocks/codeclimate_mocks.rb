# frozen_string_literal: true

def setup_codeclimate_mocks
  builds_response = Typhoeus::Response.new(code: 200, body: File.read("spec/fixtures/codeclimate_builds.json"))
  snapshots_reponse = Typhoeus::Response.new(code: 200, body: File.read("spec/fixtures/codeclimate_snapshots.json"))
  Typhoeus.stub(/builds/).and_return(builds_response)
  Typhoeus.stub(/snapshots/).and_return(snapshots_reponse)
end
