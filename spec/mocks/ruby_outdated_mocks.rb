# frozen_string_literal: true

require "bundler"

def setup_ruby_outdated_mocks
  allow(Bundler).to receive_message_chain(:definition, :validate_ruby!).and_return(nil)
  allow(Bundler::Definition).to receive(:build).and_return(DefinitionMock.new)
  allow(Bundler).to receive_message_chain(:load, :specs).and_return(used_specs_mock)
  allow_any_instance_of(DefinitionMock).to receive(:index).and_return(IndexMock.new)
end

class DefinitionMock
  def resolve_remotely!; end

  def dependencies
    specs_mock
  end
end

class SpecMock
  attr_accessor :name, :version, :git_version

  def initialize(name, version, git_version)
    @name = name
    @version = version
    @git_version = git_version
  end
end

class IndexMock
  def search(term)
    specs_mock.filter { |w| w.name[term] }
  end
end

def specs_mock
  [
    SpecMock.new("gem1", "0.1.0", "1"),
    SpecMock.new("gem2", "0.2.0", "1"),
    SpecMock.new("gem3", "0.2.0", "1"),
    SpecMock.new("gem4", "0.1.0", "1"),
    SpecMock.new("gem5", "0.2.0", "1")
  ]
end

def used_specs_mock
  [
    SpecMock.new("gem1", "0.1.0", "1"),
    SpecMock.new("gem2", "0.1.0", "1"),
    SpecMock.new("gem3", "0.1.0", "1"),
    SpecMock.new("gem4", "0.1.0", "1"),
    SpecMock.new("gem5", "0.1.0", "1")
  ]
end
