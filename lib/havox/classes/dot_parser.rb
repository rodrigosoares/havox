module Havox
  class DotParser
    attr_reader :nodes

    NODE_REGEX = /^\s*(?<name>\w+)\s?\[(?<attributes>.*)\];$/i

    def initialize(file_path)
      @file_path = file_path
      @nodes = []
      # @edges = [] # TODO: Implement parsing for edges when needed.
      parse_dot_file
    end

    def host_names
      @nodes.select { |n| n.type.eql?(:host) }.map(&:name)
    end

    private

    def parse_dot_file
      File.read(@file_path).each_line do |line|
        match = line.match(NODE_REGEX)
        next if match.nil?
        attributes = hashed_attributes(match[:attributes].to_s)
        @nodes << Havox::Node.new(match[:name].to_s, attributes)
      end
    end

    def hashed_attributes(raw_attrs)
      hash = {}
      raw_attrs.gsub('"', '').split(',').each do |str|
        field, value = str.strip.split(/\s*=\s*/)
        hash[field.to_sym] = value
      end
      hash
    end
  end
end
