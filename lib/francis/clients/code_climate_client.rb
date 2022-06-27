# frozen_string_literal: true

require_relative "api_client"

class CodeClimateClient
  attr_accessor :token, :repo_id, :branch

  def initialize
    @branch = "master"
  end

  def authorization
    "Token token=#{token}"
  end

  def builds(branch_name)
    builds_url = "https://api.codeclimate.com/v1/repos/#{repo_id}/builds?filter[state]=complete"
    unless branch_name.nil?
      builds_url += "&filter[local_ref]=#{branch_name}"
    end
    ApiClient.get(builds_url, authorization)
  end

  def snapshot(id)
    snapshot_url = "https://api.codeclimate.com/v1/repos/#{repo_id}/snapshots/#{id}"
    ApiClient.get(snapshot_url, authorization)
  end

  def status
    snapshot_id = begin
      builds("refs/heads/#{branch}")["data"][0]["relationships"]["snapshot"]["data"]["id"]
    rescue StandardError
      true
    end
    if snapshot_id == true
      snapshot_id = builds(nil)["data"][0]["relationships"]["snapshot"]["data"]["id"]
    end
    snapshot = snapshot(snapshot_id)["data"]
    rating = snapshot["attributes"]["ratings"][0]["letter"]
    issues = snapshot["meta"]["issues_count"]
    debt_ratio = snapshot["meta"]["measures"]["technical_debt_ratio"]
    debt_value = debt_ratio["value"]
    refactoring_time = debt_ratio["meta"]["remediation_time"]["value"].to_i

    {
      snapshot_id: snapshot_id,
      rating: rating,
      issues: issues,
      debt_value: debt_value,
      refactoring_time: refactoring_time
     }
  end
end
