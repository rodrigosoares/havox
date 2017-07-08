module Havox
  module Command
    class << self
      def show_ip_route(vm_name, protocol)
        vtysh_run(vm_name, "show ip route #{protocol}")
      end

      def vtysh_run(vm_name, command)
        rf_command(vm_name, "/usr/bin/vtysh -c '#{command}'")
      end

      def toggle_daemon(vm_name, daemon, activate = true)
        new_mode = activate ? 'yes' : 'no'
        old_mode = activate ? 'no' : 'yes'
        rf_command(vm_name, "/bin/sed -i 's/#{daemon.to_s}=#{old_mode}/#{daemon.to_s}=#{new_mode}/' /etc/quagga/daemons")
      end

      def copy_conf_files(vm_name, daemon)
        rf_command(vm_name, "/bin/cp /usr/share/doc/quagga/examples/#{daemon}.conf.sample /etc/quagga/#{daemon}.conf")
      end

      def toggle_service(vm_name, service, action)
        rf_command(vm_name, "#{service} #{action}")
      end

      def backup(vm_name, path)
        rf_command(vm_name, "/bin/cp #{path} #{path}.old")
      end

      def chown(vm_name, user, group, path)
        rf_command(vm_name, "/bin/chown #{user}:#{group} #{path}")
      end

      def chmod(vm_name, permissions, path)
        rf_command(vm_name, "/bin/chmod #{permissions} #{path}")
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
