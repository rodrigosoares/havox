module Havox
  module Policies
    include Havox::Command

    class << self
      private

      def config
        Havox.configuration
      end

      def cmd
        Havox::Command
      end

      def ssh_connection
        Net::SSH.start(config.merlin_host, config.merlin_user, password: config.merlin_password) do |ssh|
          yield(ssh)
        end
      end
    end

    def self.run(command)
      ssh_connection { |ssh| puts ssh.exec!(command) }
    end

    def self.compile(topology_file, policy_file, verbose = true)
      ssh_connection do |ssh|
        puts ssh.exec!(cmd.compile(topology_file, policy_file, verbose))
      end
    end
  end
end
