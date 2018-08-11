module Havox
  module RouteFlow
    class << self
      ENTRY_REGEX = /[A-Z>\*\s]{3}.*(via|is).*,.*$/

      private

      def config
        Havox.configuration
      end

      def cmd
        Havox::Command
      end

      def ssh_connection
        Net::SSH.start(config.rf_host, config.rf_user, password: config.rf_password) do |ssh|
          yield(ssh)
        end
      end

      def parse(output)
        result = output.each_line.map { |l| l.match(ENTRY_REGEX) }.compact
        result.map(&:to_s)
      end
    end

    ARP_REGEX = /(?<ip>[\d\.]+)\s(?<mac>[\w:]+)/

    def self.run(command)
      output = nil
      ssh_connection { |ssh| output = ssh.exec!(command) }
      output
    end

    def self.fetch(vm_name, protocol = nil)
      result = run(cmd.show_ip_route(vm_name, protocol))
      result = parse(result)
      result = Havox::RouteFiller.new(result).filled_routes
      result
    end

    def self.ribs(vm_names, opts = {})
      routes = []
      vm_names.each do |vm_name|
        raw_routes = fetch(vm_name)
        routes += raw_routes.map { |rr| Havox::Route.new(rr, vm_name, opts) }
      end
      routes
    end

    # OPTIMIZE: Is it OK to trust the first line of the returned results is the needed one?
    def self.arp_table(vm_names, interface)
      entries = {}
      vm_names.each do |vm_name|
        result = run(cmd.arp_awk(vm_name, interface))
        result = result.each_line.map { |l| l.match(ARP_REGEX) }.compact.first
        entries[result[:ip].to_s] = result[:mac].to_s
      end
      entries
    end
  end
end
