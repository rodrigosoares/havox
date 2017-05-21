require 'singleton'
require 'havox/version'
require 'havox/exceptions'
require 'havox/configuration'
require 'havox/modules/command'
require 'havox/modules/routes'
require 'havox/modules/policies'
require 'havox/modules/field_parser'
require 'havox/modules/openflow10/ovs/actions'
require 'havox/modules/openflow10/ovs/matches'
require 'havox/modules/openflow10/trema/actions'
require 'havox/modules/openflow10/trema/matches'
require 'havox/classes/modified_policy'
require 'havox/classes/rule'
require 'havox/classes/translator'
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
