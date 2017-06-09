module Havox
  module FieldParser
    def parsed_ipv4(ip_integer)
      ip_integer = ip_integer.to_i
      value = ip_integer.positive? ? ip_integer : (2**32 - ip_integer.abs)      # Handles two's complement integers.
      bits = value.to_s(2).rjust(32, '0')                                       # Transforms the string number into a 32-bit sequence.
      octets = bits.scan(/\d{8}/).map { |octet_bits| octet_bits.to_i(2) }       # Splits the sequence into decimal octets.
      octets.join('.')                                                          # Returns the joined octets.
    end

    def basic_action(action, arg_a = nil, arg_b = nil)
      { action: action, arg_a: arg_a, arg_b: arg_b }
    end

    def raise_unknown_action(obj)
      raise Havox::UnknownAction,
        "Unable to translate action #{obj[:action]} with arguments A:"         \
        " #{obj[:arg_a]} and B: #{obj[:arg_b]}, respectively"
    end
  end
end
