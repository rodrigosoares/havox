module Havox
  module RouteFlow
    class << self
      ENTRY_REGEX = /[(O|K|C|S|R|I|B)>\*\s]{3}.*(via|is).*,.*$/
      PROTOCOLS = [:ospf]

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
        output.each_line.map { |l| l.match(ENTRY_REGEX) }.compact
      end
    end

    def self.fetch(vm_name, protocol)
      output = nil
      ssh_connection { |ssh| output = ssh.exec!(cmd.show_ip_route(vm_name, protocol)) }
      result = parse(output)
      result.map(&:to_s)
    end

    def self.ribs
      routes = {}
      config.rf_lxc_names.each do |vm_name|
        routes[vm_name] = []
        PROTOCOLS.each do |protocol|
          raw_entries = fetch(vm_name, protocol)
          routes[vm_name] += raw_entries.map { |re| Havox::Route.new(re, protocol) }
        end
      end
      routes
    end

    def self.toggle_services(activate = true)
      ssh_connection do |ssh|
        config.rf_lxc_names.each do |vm_name|
          ssh.exec!(cmd.backup(vm_name, '/etc/quagga/daemons'))
          config.protocol_daemons.each do |daemon|
            ssh.exec!(cmd.toggle_daemon(vm_name, daemon, activate))
            ssh.exec!(cmd.copy_conf_files(vm_name, daemon))
            ssh.exec!(cmd.chown(vm_name, 'quagga', 'quaggavty', "/etc/quagga/#{daemon}.conf"))
            ssh.exec!(cmd.chmod(vm_name, '640', "/etc/quagga/#{daemon}.conf"))
          end
          ssh.exec!(cmd.toggle_service(vm_name, '/etc/init.d/quagga', 'restart'))
        end
      end
    end
  end
end
