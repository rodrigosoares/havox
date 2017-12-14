module Havox
  module DSL
    class DirectiveProxy
      def exit(switch, &block)
        eval_directive(:exit, switch, &block)
      end

      # def drop(&block)
      #   eval_directive(:drop, nil, &block)
      # end

      def topology(file_path)
        raise_invalid_topology(file_path) unless File.exists?(file_path)
        topo = Havox::Topology.new(file_path)
        Havox::Network.topology = topo
      end

      def associate(router, switch)
        Havox::Network.devices[router.to_s] = switch.to_s
      end

      private

      def eval_directive(type, switch, &block)
        directive = Havox::DSL::Directive.new(type, switch)
        directive.instance_eval(&block)
        Havox::Network.directives << directive
      end

      def raise_invalid_topology(file_path)
        raise Havox::Network::InvalidTopology,
          "invalid topology file '#{file_path}'"
      end
    end
  end
end
