require 'json'
require 'ipaddr'
require 'singleton'
require 'havox/version'
require 'havox/exceptions'
require 'havox/configuration'
require 'havox/modules/command'
require 'havox/modules/routeflow'
require 'havox/modules/merlin'
require 'havox/modules/field_parser'
require 'havox/modules/openflow10/ovs/actions'
require 'havox/modules/openflow10/ovs/matches'
require 'havox/modules/openflow10/routeflow/actions'
require 'havox/modules/openflow10/routeflow/matches'
require 'havox/modules/openflow10/trema/actions'
require 'havox/modules/openflow10/trema/matches'
require 'havox/classes/topology'
require 'havox/classes/node'
require 'havox/classes/edge'
require 'havox/classes/modified_policy'
require 'havox/classes/policy'
require 'havox/classes/rib'
require 'havox/classes/route'
require 'havox/classes/route_filler'
require 'havox/classes/rule'
require 'havox/classes/rule_sanitizer'
require 'havox/classes/rule_expander'
require 'havox/classes/translator'
require 'havox/dsl/directive.rb'
require 'havox/dsl/directive_proxy.rb'
require 'havox/dsl/network.rb'
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
