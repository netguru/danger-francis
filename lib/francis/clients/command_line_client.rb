# frozen_string_literal: true

class CommandLineClient
  def self.execute(command)
    system command
  end
end
