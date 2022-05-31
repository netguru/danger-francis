# frozen_string_literal: true

require_relative "api_client"

class FrancisApiClient
  attr_accessor :reporting_url

  def send_danger_metrics(json)
    send_metrics("#{reporting_url}danger/result", json)
  end

  def send_codeclimate_metrics(json)
    send_metrics("#{reporting_url}codeclimate/result", json)
  end

  def send_metrics(url, json)
    ApiClient.post(url, json)
  end

  private :send_metrics
end
