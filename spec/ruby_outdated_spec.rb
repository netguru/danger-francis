# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)
require_relative "../lib/francis/outdated/ruby_outdated"
require_relative "mocks/ruby_outdated_mocks"

describe RubyOutdated do
  before do
    @dangerfile = testing_dangerfile
    @my_plugin = @dangerfile.francis
  end

  it "Ruby outdated dependencies information is properly returned" do
    setup_ruby_outdated_mocks
    result = RubyOutdated.new(@my_plugin).outdated
    expect(result[:total]).to eq(5)
    expect(result[:outdated]).to eq(3)
  end

  it "When Gemfile is missing proper message should be logged" do
    allow(File).to receive(:exist?).with("Gemfile").and_return(false)
    allow(Logger).to receive(:log) do |message|
      expect(message).to eq("Gemfile not found")
    end
    result = RubyOutdated.new(@my_plugin).outdated
  end
end
