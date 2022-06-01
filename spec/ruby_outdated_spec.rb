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
    expect(result[:total]).to eq(4)
    expect(result[:outdated]).to eq(3)
  end

  it "Ruby outdated dependencies information is properly returned when nothing to update" do
    setup_ruby_outdated_noting_to_update_mocks
    result = RubyOutdated.new(@my_plugin).outdated
    expect(result[:total]).to eq(4)
    expect(result[:outdated]).to eq(0)
  end
end
