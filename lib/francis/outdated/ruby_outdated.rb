# frozen_string_literal: true

require "bundler"
require_relative "../clients/command_line_client"
require_relative "../utils/logger"

class RubyOutdated
  attr_accessor :plugin

  def initialize(plugin)
    @plugin = plugin
  end

  def outdated
    unless File.exist?("Gemfile")
      Logger.log("Gemfile not found")
      return { total: 0, outdated: 0 }
    end
    return bundler_outdated
  end

  def bundler_outdated
    outdated_dependencies_count = 0
    Bundler.definition.validate_ruby!
    current_specs = Bundler.load.specs
    definition = Bundler::Definition.build("Gemfile", "Gemfile.lock", false)
    definition.resolve_remotely!
    total_dependencies_count = definition.dependencies.length
    current_specs.sort_by(&:name).each do |current_spec|
      active_spec = definition.index.search(current_spec.name).sort_by(&:version)
      active_spec = active_spec.last
      next if active_spec.nil?

      gem_outdated = Gem::Version.new(active_spec.version) > Gem::Version.new(current_spec.version)
      git_outdated = current_spec.git_version != active_spec.git_version
      if (gem_outdated || git_outdated) && definition.dependencies.any? { |w| w.name[active_spec.name] }
        outdated_dependencies_count += 1
      end
    end
    return { total: total_dependencies_count, outdated: outdated_dependencies_count }
  end
end
