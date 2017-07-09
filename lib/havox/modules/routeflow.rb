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
      routes = {}
      vm_names.each do |vm_name|
        routes[vm_name] = []
        raw_entries = fetch(vm_name)
        routes[vm_name] += raw_entries.map { |re| Havox::Route.new(re, opts) }
      end
      routes
    end
  end
end
