module Havox
  module Policies
    include Havox::Command

    class << self
      private

      SEPARATOR_REGEX   = /On\sswitch\s\d+/
      RULES_BLOCK_REGEX = /(?<=OpenFlow\srules\s)\(\d+\):#{SEPARATOR_REGEX}(.+)(?=Queue\sConfigurations)/

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

      def parse(result)
        result = result.tr("\n\t", '')                                          # Removes line break and tab characters.
        result = result.scan(RULES_BLOCK_REGEX).flatten.first                   # Matches OpenFlow rules block.
        result.split(SEPARATOR_REGEX)                                           # Splits the block into separated rules.
      end
    end

    def self.run(command)
      output = nil
      ssh_connection { |ssh| output = ssh.exec!(command) }
      output
    end

    def self.compile(topology_file, policy_file, verbose = true)
      result = run(cmd.compile(topology_file, policy_file, verbose))
      parse(result)
    end
  end
end
