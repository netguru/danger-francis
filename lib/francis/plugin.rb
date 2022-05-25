# frozen_string_literal: true

require "typhoeus"
require_relative "ios_outdated"
require_relative "flutter_outdated"
require_relative "android_outdated"
require_relative "gem_version"
require_relative "code_climate_client"
require_relative "francis_api_client"

module Danger
  class DangerFrancisError < StandardError
  end

  # This plugin allows uploading data to Francis
  # @see  netguru/danger-francis
  #
  # @example Base configuration needed for sending report
  #
  #          francis.reporting_url = "https://correct.address.com/api/francis"
  #          francis.stack = "ios"
  #          francis.ci_type = "bitrise"
  #          francis.project_id = "uuid"
  #          francis.coverage = 12
  #          francis.lint_errors = 10
  #          francis.lint_warnings = 21
  #          francis.send_report # sends the report
  #
  # @tags netguru, francis, quality
  #
  class DangerFrancis < Plugin
    # Base API Url for francis.
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

    # Access token for codeclimate project
    attr_accessor :codeclimate_token

    # CodeClimate repository id
    attr_accessor :codeclimate_repo_id

    # Main branch for the project[optional]
    # Default: master
    attr_accessor :codeclimate_main_branch

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

      result = { total: 0, outdated: 0 }

      case stack
      when "ios"
        result = ios_outdated_dependencies
      when "flutter"
        result = flutter_outdated_dependencies
      when "android"
        return android_outdated_dependencies
      end

      return result
    end

    def danger_metrics_json
      {
        "project_id": project_id,
        "code_coverage": coverage.to_f,
        "linter_result": {
          "errors": lint_errors,
          "warnings": lint_warnings
        },
        "dependencies": {
           "count": dependencies_report[:total],
           "outdated_count": dependencies_report[:outdated]
        },
        "ci_data": {
          "build_time": build_time_value
        },
        "pluginVersion": Francis::VERSION
      }
    end

    def codeclimate_metrics_json
      client = CodeClimateClient.new
      unless codeclimate_main_branch.nil?
        client.branch = codeclimate_main_branch
      end
      client.token = codeclimate_token
      client.repo_id = codeclimate_repo_id
      status = client.status
      {
        "project_id": project_id,
        "snapshot_id": status[:snapshot_id],
        "overall_rating": status[:rating],
        "total_refactoring_time": status[:refactoring_time],
        "technical_debt": status[:debt_value],
        "code_analysis_result": {
          "total_issues": status[:issues],
          "blocker_issues": 0,
          "critical_issues": 0,
          "major_issues": 0,
          "minor_issues": 0
        },
        "pluginVersion": Francis::VERSION
      }
    end

    ### Methods

    # Sends the report to Francis
    #
    # @return  [void]
    def send_report
      check_properties
      message "Sending project state-of-health report to Francis"
      message "Code coverage: #{coverage.round(2)}%"
      message "Linter errors: #{lint_errors}"
      message "Linter warnings: #{lint_warnings}"
      message "Build time: #{(build_time_value / 60).to_i}min"
      message "Outdated dependencies count: #{dependencies_report[:outdated]} (out of #{dependencies_report[:total]} in total)"
      francis_api_client = FrancisApiClient.new
      francis_api_client.reporting_url = reporting_url
      begin
        francis_api_client.send_danger_metrics(danger_metrics_json)
      rescue StandardError => e
        message "Danger Metrics NOT sent to Francis due to error: #{e.message}"
      end
      if !codeclimate_token.nil? && !codeclimate_repo_id.nil?
        francis_api_client.send_codeclimate_metrics(codeclimate_metrics_json)
      end
    end

    def check_properties
      check_property(:reporting_url)
      check_property(:stack)
      check_property(:ci_type)
      check_property(:project_id)
      check_property(:coverage)
      check_property(:lint_errors)
      check_property(:lint_warnings)
    end

    def check_property(property)
      raise DangerFrancisError, "#{property} property is empty" if send(property.to_s).nil?
    end

    private :build_time_value, :dependencies_report, :check_properties, :danger_metrics_json, :codeclimate_metrics_json, :check_property
  end
end
