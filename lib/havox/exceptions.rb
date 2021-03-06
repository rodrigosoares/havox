module Havox
  module Merlin
    class ParsingError < StandardError; end
  end

  module RouteFlow
    class UnknownProtocol < StandardError; end
  end

  module Trema
    class UnpredictedAction < StandardError; end
  end

  module Network
    class InvalidTopology < StandardError; end
  end

  class UnknownTranslator < StandardError; end
  class UnknownAction < StandardError; end
  class OperationError < StandardError; end
end
