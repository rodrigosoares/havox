module Havox
  module DSL
    class SnippetProxy
      def balance(&block)
        eval_snippet(:balance, &block)
      end

      def drop(&block)
        eval_snippet(:drop, &block)
      end

      private

      def eval_snippet(action, &block)
        snippet = Havox::DSL::Snippet.new(action)
        snippet.instance_eval(&block)
        Havox::Network.snippets << snippet
      end
    end
  end
end
