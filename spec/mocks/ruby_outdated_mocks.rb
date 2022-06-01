# frozen_string_literal: true

def setup_ruby_outdated_base_mocks
  gemfile_mock = File.read("spec/fixtures/Gemfile.txt")
  allow(File).to receive(:exist?).with("Gemfile").and_return(true)
  allow(File).to receive(:open).with("Gemfile", "rb").and_return(gemfile_mock)
end

def setup_ruby_outdated_mocks
  setup_ruby_outdated_base_mocks
  bundler_outdated_mock = File.read("spec/fixtures/bundler_outdated.txt")
  allow(CommandLineClient).to receive(:execute).with("bundler outdated --only-explicit").and_return(bundler_outdated_mock)
end

def setup_ruby_outdated_noting_to_update_mocks
  setup_ruby_outdated_base_mocks
  bundler_outdated_mock = File.read("spec/fixtures/bundler_outdated_up_to_date.txt")
  allow(CommandLineClient).to receive(:execute).with("bundler outdated --only-explicit").and_return(bundler_outdated_mock)
end
