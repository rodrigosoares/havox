require 'havox/version'
require 'havox/configuration'
require 'net/ssh'

module Havox
  class << self
    attr_accessor :configuration

    ENTRY_REGEX = /^\w.*\s((?:[0-9]{1,3}\.){3}[0-9]{1,3}\/[0-9]{1,2}).*$/

    private

    def route_command(vm_name, protocol)
      "sudo lxc-attach -n #{vm_name} -- /usr/bin/vtysh -c 'show ip route #{protocol}'"
    end

    def ssh_connection
      Net::SSH.start(configuration.rf_host, configuration.rf_user, password: configuration.rf_password) do |ssh|
        yield(ssh)
      end
    end

    def parse_routes(table_str)
      table_str.scan(ENTRY_REGEX).flatten
    end
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

  def self.fetch(vm_name, protocol = configuration.protocol)
    ssh_connection do |ssh|
      output = ssh.exec!(route_command(vm_name, protocol))
      parse_routes(output)
    end
  end

  def self.fetch_all(protocol = configuration.protocol)
    routes = {}
    ssh_connection do |ssh|
      configuration.rf_vm_names.each do |vm_name|
        output = ssh.exec!(route_command(vm_name, protocol))
        routes[vm_name] = parse_routes(output)
      end
    end
    routes
  end
end
