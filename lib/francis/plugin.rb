# frozen_string_literal: true

require "typhoeus"
require_relative "ios_outdated"
require_relative "flutter_outdated"
require_relative "android_outdated"
require_relative "gem_version"

module Danger
  # This plugin allows uploading data to Francis
  # @see  netguru/danger-francis
  #
  class DangerFrancis < Plugin
    # Url of the endpoint where report will be sent
    attr_accessor :reporting_url

    # Stack of the project
    # Available values: android, ios, reactnative, flutter, ror, python
    attr_accessor :stack

    # CI type
    # Available values: bitrise, circleci
    attr_accessor :ci_type

    # Valid Project id from Francis
    attr_accessor :project_id

    # Current code coverage in percentage
    attr_accessor :coverage

    # Number of lint errors
    attr_accessor :lint_errors

    # Number of lint warnings
    attr_accessor :lint_warnings

    # Build time in seconds [optional]
    # Automatically calculated when ci_type = bitrise
    attr_accessor :build_time

    # Number of dependencies used in the project[optional]
    # Automatically calculated when stack = ios, flutter or android
    attr_accessor :dependencies_count

    # Number of outdated dependencies used in the project[optional]
    # Automatically calculated when stack = ios, flutter or android
    attr_accessor :outdated_dependencies_count

    ### Calculated properties

    def build_time_value
      unless build_time.nil?
        return build_time
      end

      build_start_timestamp = ENV["BITRISE_BUILD_TRIGGER_TIMESTAMP"]
      if ci_type == "bitrise" && !build_start_timestamp.nil?
        current_timestamp = Time.now.to_i
        return current_timestamp.to_i - build_start_timestamp.to_i
      end
      return 0
    end

    def dependencies_report
      unless dependencies_count.nil? || outdated_dependencies_count.nil?
        return { total: dependencies_count, outdated: outdated_dependencies_count }
      end

      case stack
      when "ios"
        return ios_outdated_dependencies
      when "flutter"
        return flutter_outdated_dependencies
      when "android"
        return android_outdated_dependencies
      end

      return { total: 0, outdated: 0 }
    end

    ### Methods

    # Sends the report to Francis
    #
    def send_report
      check_properties
      dependencies = dependencies_report
      message "Sending project state-of-health report to Francis"
      message "Code coverage: #{coverage.round(2)}"
      message "Linter errors: #{lint_errors} and warnings: #{lint_warnings}"
      message "Build time: #{(build_time_value / 60).to_i}min"
      message "Total outdated dependencies count: #{dependencies[:outdated]} (out of #{dependencies[:total]} in total)"

      json = {
        "project_id": project_id,
        "code_coverage": coverage.to_f,
        "linter_result": {
          "errors": lint_errors,
          "warnings": lint_warnings
        },
        "dependencies": {
           "count": dependencies[:total],
           "outdated_count": dependencies[:outdated]
        },
        "ci_data": {
          "build_time": build_time_value
        },
        "pluginVersion": Francis::VERSION
      }
      puts json

      begin
        send_francis_request(json)
      rescue StandardError => e
        message "Data NOT sent to Francis due to error: #{e.message}"
      end
    end

    def check_properties
      throw "reporting_url property is empty" if reporting_url.nil?
      throw "stack property is empty" if stack.nil?
      throw "ci_type property is empty" if ci_type.nil?
      throw "project_id property is empty" if project_id.nil?
      throw "coverage property is empty" if coverage.nil?
      throw "lint_errors property is empty" if lint_errors.nil?
      throw "lint_warnings property is empty" if lint_warnings.nil?
    end

    def send_francis_request(json)
      request = Typhoeus::Request.new(
        reporting_url,
        method: :post,
        body: JSON.dump(json),
        headers: { "Content-Type": "application/json" }
      )
      resp = request.run
      unless resp.success?
        warn("Send failed with code: #{resp.code} body: #{resp.body}")
      end
    end

    private :build_time_value, :send_francis_request, :dependencies_report, :check_properties
  end
end
