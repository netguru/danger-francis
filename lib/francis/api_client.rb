# frozen_string_literal: true

require "typhoeus"
require "json"

class ApiClient
  def self.post(url, json, authorization = nil)
    self.request(:post, url, json, authorization)
  end

  def self.get(url, authorization = nil)
    self.request(:get, url, nil, authorization)
  end

  def self.request(method, url, json_body, authorization = nil)
    headers = { "Authorization": authorization }
    body = nil
    unless json_body.nil?
      headers["Content-Type"] = "application/json"
      body = JSON.dump(json_body)
    end

    request = Typhoeus::Request.new(
      url,
      method: method,
      body: body,
      headers: headers
    )
    resp = request.run
    if !resp.success?
      warn("Send failed with code: #{resp.code} body: #{resp.body}")
    elsif !resp.body.nil?
      return JSON.parse(resp.body)
    end
  end
end
