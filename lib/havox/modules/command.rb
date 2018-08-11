module Havox
  module Command
    class << self
      def show_ip_route(vm_name, protocol)
        vtysh_run(vm_name, "show ip route #{protocol}")
      end

      def arp_awk(vm_name, interface)
        rf_command(
          vm_name,
          "/usr/sbin/arp -ni #{interface} | grep #{interface} | awk '{print $1, $3}'"
        )
      end

      def vtysh_run(vm_name, command)
        rf_command(vm_name, "/usr/bin/vtysh -c '#{command}'")
      end

      def compile(topology_file, policy_file)
        merlin_command("-topo #{topology_file} #{policy_file} -verbose")
      end

      private

      def rf_command(vm_name, command)
        "sudo lxc-attach -n #{vm_name} -- #{command}"
      end

      def merlin_command(args)
        env_vars = "GUROBI_HOME=\"#{Havox.configuration.gurobi_path}\" " \
                   'PATH="${PATH}:${GUROBI_HOME}/bin" ' \
                   'LD_LIBRARY_PATH="${GUROBI_HOME}/lib" ' \
                   'GRB_LICENSE_FILE="${GUROBI_HOME}/gurobi.lic"'
        "#{env_vars} #{Havox.configuration.merlin_path}/Merlin.native #{args}"
      end
    end
  end
end
