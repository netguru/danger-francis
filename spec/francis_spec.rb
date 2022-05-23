# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)

module Danger
  describe Danger::DangerFrancis do
    it "should be a plugin" do
      expect(Danger::DangerFrancis.new(nil)).to be_a Danger::Plugin
    end

    describe "with Dangerfile" do
      before do
        @dangerfile = testing_dangerfile
        @my_plugin = @dangerfile.francis
      end

      it "Errors are raised when values are not passed" do
        expect {
          @my_plugin.send_report
        }.to raise_error(DangerFrancisError, "reporting_url property is empty")

        @my_plugin.reporting_url = "fixture"
        expect {
          @my_plugin.send_report
        }.to raise_error(DangerFrancisError, "stack property is empty")

        @my_plugin.stack = "ios"
        expect {
          @my_plugin.send_report
        }.to raise_error(DangerFrancisError, "ci_type property is empty")

        @my_plugin.ci_type = "CircleCI"
        expect {
          @my_plugin.send_report
        }.to raise_error(DangerFrancisError, "project_id property is empty")

        @my_plugin.project_id = "fixture"
        expect {
          @my_plugin.send_report
        }.to raise_error(DangerFrancisError, "coverage property is empty")

        @my_plugin.coverage = 0
        expect {
          @my_plugin.send_report
        }.to raise_error(DangerFrancisError, "lint_errors property is empty")

        @my_plugin.lint_errors = 0
        expect {
          @my_plugin.send_report
        }.to raise_error(DangerFrancisError, "lint_warnings property is empty")

        @my_plugin.lint_warnings = 0
        @my_plugin.send_report
      end
    end
  end
end
