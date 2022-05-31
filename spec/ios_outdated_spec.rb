# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)
require_relative "../lib/francis/outdated/ios_outdated"

describe IOSOutdated do
  before do
    Typhoeus::Expectation.clear
    @dangerfile = testing_dangerfile
    @my_plugin = @dangerfile.francis
  end

  def mock_pods
    pod_lock_mock = File.read("spec/fixtures/Podfile.lock")
    pod_outdated_mock = File.read("spec/fixtures/pod_outdated.txt")
    allow(File).to receive(:exist?).with("Podfile.lock").and_return(true)
    allow(File).to receive(:open).with("Podfile.lock", "rb").and_return(pod_lock_mock)
    allow(CommandLineClient).to receive(:execute).with("pod outdated").and_return(pod_outdated_mock)
  end

  def mock_carthage
    carthage_resolved_mock = File.read("spec/fixtures/Cartfile.resolved")
    carthage_outdated_mock = File.read("spec/fixtures/carthage_outdated.txt")
    allow(File).to receive(:exist?).with("Cartfile.resolved").and_return(true)
    allow(File).to receive(:open).with("Cartfile.resolved", "rb").and_return(carthage_resolved_mock)
    allow(CommandLineClient).to receive(:execute).with("carthage outdated").and_return(carthage_outdated_mock)
  end

  it "iOS dependencies information is properly returned when only pods mocked" do
    mock_pods
    allow(File).to receive(:exist?).with("Cartfile.resolved").and_return(false)
    result = IOSOutdated.new(@my_plugin).outdated
    expect(result[:total]).to eq(2)
    expect(result[:outdated]).to eq(1)
  end

  it "iOS dependencies information is properly returned when only carthage mocked" do
    mock_carthage
    allow(File).to receive(:exist?).with("Podfile.lock").and_return(false)
    result = IOSOutdated.new(@my_plugin).outdated
    expect(result[:total]).to eq(5)
    expect(result[:outdated]).to eq(3)
  end

  it "iOS dependencies information is properly returned" do
    mock_pods
    mock_carthage
    result = IOSOutdated.new(@my_plugin).outdated
    expect(result[:total]).to eq(7)
    expect(result[:outdated]).to eq(4)
  end
end
