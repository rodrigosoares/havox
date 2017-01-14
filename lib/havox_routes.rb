require 'havox_routes/version'
require 'havox_routes/configuration'
require 'net/ssh'

module HavoxRoutes
  class << self
    attr_accessor :configuration

    private

    def route_command(vm_name, protocol)
      "sudo lxc-attach -n #{vm_name} -- /usr/bin/vtysh -c 'show ip route #{protocol}'"
    end

    def ssh_connection
      Net::SSH.start(configuration.rf_host, configuration.rf_user, password: configuration.rf_password) do |ssh|
        yield(ssh)
      end
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
      ssh.exec!(route_command(vm_name, protocol))
    end
  end

  def self.fetch_all(protocol = configuration.protocol)
    routes = {}
    ssh_connection do |ssh|
      configuration.rf_vm_names.each do |vm_name|
        routes[vm_name] = ssh.exec!(route_command(vm_name, protocol))
      end
    end
    routes
  end
end
