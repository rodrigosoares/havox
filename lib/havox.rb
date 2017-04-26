require 'havox/version'
require 'havox/exceptions'
require 'havox/configuration'
require 'havox/modules/command'
require 'havox/modules/routes'
require 'havox/modules/policies'
require 'havox/modules/openflow10/actions'
require 'havox/modules/openflow10/matches'
require 'havox/classes/arp_entry'
require 'havox/classes/arp_table'
require 'havox/classes/rule'
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
