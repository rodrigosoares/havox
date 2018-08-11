module Havox
  class Topology
    attr_reader :nodes, :edges

    NODE_REGEX = /^\s*(?<name>\w+)\s?\[(?<attributes>.*)\];$/i
    EDGE_REGEX = /^\s*(?<from>\w+)\s?->\s?(?<to>\w+)\s?\[(?<attributes>.*)\];$/i

    def initialize(file_path)
      @file_path = file_path
      @nodes = []
      @edges = []
      parse_dot_file
    end

    def hosts
      @nodes.select(&:host?)
    end

    def host_names
      hosts.map(&:name)
    end

    def ips_by_switch
      switches = @nodes.select(&:switch?)
      switch_ip_hash = {}
      switches.each { |s| switch_ip_hash[s.name] = s.attributes[:ip] }
      switch_ip_hash
    end

    def hosts_by_switch
      hash = {}
      exit_edges.each do |e|
        if hash[e.from.name].nil?
          hash[e.from.name] = [e.to.name]
        else
          hash[e.from.name] << e.to.name
        end
      end
      hash
    end

    def border_switches
      exit_edges.map(&:from).uniq
    end

    private

    def exit_edges
      @edges.select { |e| e.from.switch? && e.to.host? }
    end

    def parse_dot_file
      File.read(@file_path).each_line do |line|
        parse_node(line)
        parse_edge(line)
      end
    end

    def parse_node(line)
      match = line.match(NODE_REGEX)
      unless match.nil?
        attributes = hashed_attributes(match[:attributes].to_s)
        @nodes << Havox::Node.new(match[:name].to_s, attributes)
      end
    end

    def parse_edge(line)
      match = line.match(EDGE_REGEX)
      unless match.nil?
        attributes = hashed_attributes(match[:attributes].to_s)
        node_from = @nodes.find { |n| n.name.eql?(match[:from].to_s) }
        node_to = @nodes.find { |n| n.name.eql?(match[:to].to_s) }
        @edges << Havox::Edge.new(node_from, node_to, attributes)
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
