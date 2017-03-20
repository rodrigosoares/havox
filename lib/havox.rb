require 'havox/version'
require 'havox/exceptions'
require 'havox/configuration'
require 'havox/command'
require 'havox/routes'
require 'havox/policies'
require 'havox/rule'
require 'net/ssh'
require 'net/scp'

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
