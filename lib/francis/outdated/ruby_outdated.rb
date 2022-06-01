# frozen_string_literal: true

require_relative "../clients/command_line_client"

class RubyOutdated
  attr_accessor :plugin

  def initialize(plugin)
    @plugin = plugin
  end

  def outdated
    total_dependencies_count = 0
    outdated_dependencies_count = 0
    if File.exist?("Gemfile")
      gemfile_file_content = File.open("Gemfile", "rb", &:read)
      gemfile_file_content.each_line do |line|
        if line.include? "gem "
          total_dependencies_count += 1
        end
      end

      bundler_message = CommandLineClient.execute("bundler outdated --only-explicit")
      if bundler_message.match(/Bundle up to date./)
        bundler_message = "Bundle up to date."
      end

      index = bundler_message.index(/Gem /)
      unless index.nil?
        bundler_message = bundler_message[index...bundler_message.size]
        outdated_dependencies_count += bundler_message.lines.count - 1
      end
      plugin.message("Bundler: #{bundler_message}")
    end
    return { total: total_dependencies_count, outdated: outdated_dependencies_count }
  end
end
