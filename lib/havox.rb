require 'havox/version'
require 'havox/configuration'
require 'havox/command'
require 'havox/routes'
require 'net/ssh'

module Havox
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
