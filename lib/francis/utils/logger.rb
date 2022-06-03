# frozen_string_literal: true

class Logger
  @enabled = true

  class << self
    attr_accessor :enabled
  end

  def self.log(message)
    if @enabled
      puts message
    end
  end
end
