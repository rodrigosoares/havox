module Havox
  class SnippetProxy
    def balance(&block)
      eval_snippet(:balance, &block)
    end

    def drop(&block)
      eval_snippet(:drop, &block)
    end

    private

    def eval_snippet(action, &block)
      snippet_meta = Havox::SnippetMetadata.new(action)
      snippet_meta.instance_eval(&block)
      Havox::Network.snippets << snippet_meta
    end
  end
end
