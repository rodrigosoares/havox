module Havox
  module Policies
    include Havox::Command

    class << self
      private

      ERROR_REGEX       = /Uncaught\sexception:\s*(.+)Raised/
      BASENAME_REGEX    = /^.+\/(?<name>[^\/]+)$/
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
        result = result.tr("\n", '').tr("\t", ' ')                              # Removes line break and tab characters.
        check_for_errors(result)                                                # Raises an error if Merlin has errored.
        result = result.scan(RULES_BLOCK_REGEX).flatten.first                   # Matches OpenFlow rules block.
        return [] if result.nil?                                                # Returns an empty array if no rules were created.
        result = result.split(SEPARATOR_REGEX)                                  # Splits the block into separated rules.
        result.map(&:to_s)                                                      # Converts NetSSH special string to string.
      end

      def check_for_errors(result)
        error_msg = result.scan(ERROR_REGEX).flatten.first
        raise Havox::MerlinError, error_msg unless error_msg.nil?
      end

      def basename(path)
        path.match(BASENAME_REGEX)[:name]
      end
    end

    def self.run(command)
      output = nil
      ssh_connection { |ssh| output = ssh.exec!(command) }
      output
    end

    def self.upload!(file, dst = nil)
      dst ||= "#{config.merlin_path}/examples/"
      ssh_connection { |ssh| ssh.scp.upload!(file, dst) }
      true
    end

    def self.compile(topology_file, policy_file)
      rules = []
      result = run(cmd.compile(topology_file, policy_file))                     # Runs Merlin in the remote VM and retrieves its output.
      result = parse(result)                                                    # Parses the output into raw rules.
      result.each { |raw_rule| rules << Havox::Rule.new(raw_rule) }             # Creates Rule instances for each raw rule.
      rules
    end

    def self.compile!(topology_file, policy_file, dst = nil)
      dst ||= "#{config.merlin_path}/examples/"
      if upload!(topology_file, dst) && upload!(policy_file, dst)
        topology_file = "#{dst}#{basename(topology_file)}"
        policy_file = "#{dst}#{basename(policy_file)}"
        compile(topology_file, policy_file)
      end
    end
  end
end
