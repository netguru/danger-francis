# frozen_string_literal: true

require "open3"

class CommandLineClient
  def self.execute(command)
    stdout, stderr, = Open3.capture3(command)
    return stdout.nil? ? stderr : stdout
  end
end
