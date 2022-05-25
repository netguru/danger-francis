# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)
require_relative "mocks/codeclimate_mocks"

# rubocop:disable Metrics/ModuleLength
module Danger
  describe Danger::DangerFrancis do
    it "should be a plugin" do
      expect(Danger::DangerFrancis.new(nil)).to be_a Danger::Plugin
    end

    describe "with Dangerfile" do
      before do
        @dangerfile = testing_dangerfile
        @my_plugin = @dangerfile.francis
        Typhoeus::Expectation.clear
        reponse = Typhoeus::Response.new(code: 200)
        Typhoeus.stub(/fixture/).and_return(reponse)
      end

      def prepare_plugin(include_base_metrics: false)
        @my_plugin.reporting_url = "fixture"
        @my_plugin.stack = "ios"
        @my_plugin.ci_type = "circleci"
        @my_plugin.project_id = "fixture"
        if include_base_metrics
          @my_plugin.coverage = 10
          @my_plugin.lint_errors = 20
          @my_plugin.lint_warnings = 100
        end
      end

      it "Errors are raised when values are not passed" do
        expect do
          @my_plugin.send_report
        end.to raise_error(DangerFrancisError, "reporting_url property is empty")

        @my_plugin.reporting_url = "fixture"
        expect do
          @my_plugin.send_report
        end.to raise_error(DangerFrancisError, "stack property is empty")

        @my_plugin.stack = "ios"
        expect do
          @my_plugin.send_report
        end.to raise_error(DangerFrancisError, "ci_type property is empty")

        @my_plugin.ci_type = "circleci"
        expect do
          @my_plugin.send_report
        end.to raise_error(DangerFrancisError, "project_id property is empty")

        @my_plugin.project_id = "fixture"
        expect do
          @my_plugin.send_report
        end.to raise_error(DangerFrancisError, "coverage property is empty")

        @my_plugin.coverage = 0
        expect do
          @my_plugin.send_report
        end.to raise_error(DangerFrancisError, "lint_errors property is empty")

        @my_plugin.lint_errors = 0
        expect do
          @my_plugin.send_report
        end.to raise_error(DangerFrancisError, "lint_warnings property is empty")

        @my_plugin.lint_warnings = 0
        @my_plugin.send_report
      end

      it "Required values are properly reported" do
        prepare_plugin
        coverage = rand(0.0...100.0)
        lint_errors = rand(0...100)
        lint_warnings = rand(0...100)
        @my_plugin.coverage = coverage
        @my_plugin.lint_errors = lint_errors
        @my_plugin.lint_warnings = lint_warnings
        @my_plugin.send_report
        messages = @dangerfile.status_report[:messages]
        expect(messages).to include("Sending project state-of-health report to Francis")
        expect(messages).to include("Code coverage: #{coverage.round(2)}%")
        expect(messages).to include("Linter errors: #{lint_errors}")
        expect(messages).to include("Linter warnings: #{lint_warnings}")
        expect(messages).to include("Build time: 0min")
        expect(messages).to include("Outdated dependencies count: 0 (out of 0 in total)")
      end

      it "Passed dependencies information is properly reported" do
        prepare_plugin(include_base_metrics: true)
        dependencies_count = rand(5...50)
        outdated_dependencies_count = rand(0...dependencies_count)
        @my_plugin.dependencies_count = dependencies_count
        @my_plugin.outdated_dependencies_count = outdated_dependencies_count
        @my_plugin.send_report
        messages = @dangerfile.status_report[:messages]
        expect(messages).to include("Outdated dependencies count: #{outdated_dependencies_count} (out of #{dependencies_count} in total)")
      end

      it "Passed build time is properly reported" do
        prepare_plugin(include_base_metrics: true)
        build_time = rand(100...1000)
        @my_plugin.build_time = build_time
        @my_plugin.send_report
        messages = @dangerfile.status_report[:messages]
        expect(messages).to include("Build time: #{(build_time / 60).to_i}min")
      end

      it "Build time for Bitrise is properly calculated and reported" do
        prepare_plugin(include_base_metrics: true)
        @my_plugin.ci_type = "bitrise"

        current_timestamp = Time.now
        start_timestamp = current_timestamp.to_i - rand(100...2000)
        allow(Time).to receive(:now).and_return(current_timestamp)
        allow(ENV).to receive(:[]).with("BITRISE_BUILD_TRIGGER_TIMESTAMP").and_return(start_timestamp)

        @my_plugin.send_report
        build_time = current_timestamp.to_i - start_timestamp
        messages = @dangerfile.status_report[:messages]
        expect(messages).to include("Build time: #{(build_time / 60).to_i}min")
      end

      it "Danger data is properly sent to api" do
        Typhoeus::Expectation.clear
        prepare_plugin
        coverage = rand(0.0...100.0)
        lint_errors = rand(0...100)
        lint_warnings = rand(0...100)
        build_time = rand(100...1000)
        dependencies_count = rand(5...50)
        outdated_dependencies_count = rand(0...dependencies_count)

        @my_plugin.reporting_url = "fixture"
        @my_plugin.coverage = coverage
        @my_plugin.lint_errors = lint_errors
        @my_plugin.lint_warnings = lint_warnings
        @my_plugin.build_time = build_time
        @my_plugin.dependencies_count = dependencies_count
        @my_plugin.outdated_dependencies_count = outdated_dependencies_count
        all_expectations_fulfilled = false
        Typhoeus.stub(/fixture/) do |request|
          body = JSON[request.options[:body]]
          expect(body["project_id"]).to eq("fixture")
          expect(body["code_coverage"]).to eq(coverage)
          expect(body["linter_result"]["errors"]).to eq(lint_errors)
          expect(body["linter_result"]["warnings"]).to eq(lint_warnings)
          expect(body["dependencies"]["count"]).to eq(dependencies_count)
          expect(body["dependencies"]["outdated_count"]).to eq(outdated_dependencies_count)
          expect(body["ci_data"]["build_time"]).to eq(build_time)
          expect(body["pluginVersion"]).to eq(Francis::VERSION)
          all_expectations_fulfilled = true
          Typhoeus::Response.new(code: 200)
        end
        @my_plugin.send_report
        expect(all_expectations_fulfilled).to eq(true)
      end

      it "CodeClimate Data is sent to francis api" do
        Typhoeus::Expectation.clear
        prepare_plugin(include_base_metrics: true)
        setup_codeclimate_mocks
        reponse = Typhoeus::Response.new(code: 200)
        Typhoeus.stub(/danger/).and_return(reponse)
        @my_plugin.codeclimate_token = "fixture_token"
        @my_plugin.codeclimate_repo_id = "fixture_repo_id"
        all_expectations_fulfilled = false
        Typhoeus.stub(%r{codeclimate/result}) do |request|
          body = JSON[request.options[:body]]
          expect(body["project_id"]).to eq("fixture")
          expect(body["snapshot_id"]).to eq("fixture_id")
          expect(body["overall_rating"]).to eq("C")
          expect(body["total_refactoring_time"]).to eq(262.0)
          expect(body["technical_debt"]).to eq(10.270369550217175)
          expect(body["code_analysis_result"]["total_issues"]).to eq(6)
          expect(body["pluginVersion"]).to eq(Francis::VERSION)
          all_expectations_fulfilled = true
          Typhoeus::Response.new(code: 200)
        end
        @my_plugin.send_report
        expect(all_expectations_fulfilled).to eq(true)
      end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
