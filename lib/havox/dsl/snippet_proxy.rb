module Havox
  module DSL
    class SnippetProxy
      def balance(&block)
        eval_snippet(:balance, &block)
      end

      def drop(&block)
        eval_snippet(:drop, &block)
      end

      def topology(file_path)
        raise_invalid_topology(file_path) unless File.exists?(file_path)
        topo = Havox::Topology.new(file_path)
        Havox::Network.topology = topo
      end

      private

      def eval_snippet(action, &block)
        snippet = Havox::DSL::Snippet.new(action)
        snippet.instance_eval(&block)
        Havox::Network.snippets << snippet
      end

      def raise_invalid_topology(file_path)
        raise Havox::Network::InvalidTopology,
          "invalid topology file '#{file_path}'"
      end
    end
  end
end
