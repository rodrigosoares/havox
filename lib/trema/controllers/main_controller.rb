require 'havox'
require 'colorize'

class MainController < Trema::Controller
  timer_event :datapath_statuses, interval: 10.sec

  def start(_argv)
    initialize_instance_vars
    logger.info "Generating rules based on the policies defined in #{ENV['HAVOX_MERLIN_POLICY'].bold}" \
                " over the topology #{ENV['HAVOX_MERLIN_TOPOLOGY'].bold}..."
    @opts[:force] = ENV['HAVOX_FORCE'].eql?('true')
    @opts[:basic] = ENV['HAVOX_BASIC'].eql?('true')
    @opts[:expand] = ENV['HAVOX_EXPAND'].eql?('true')
    @opts[:output] = ENV['HAVOX_OUTPUT'].eql?('true')
    @opts[:syntax] = ENV['HAVOX_SYNTAX'].to_sym unless ENV['HAVOX_SYNTAX'].empty?
    logger.info 'Havox will ignore field conflicts in rules generated by Merlin'.blue if @opts[:force]
    logger.info 'Havox will automatically append policies for ARP and ICMP protocols'.blue if @opts[:basic]
    logger.info 'Havox will expand generated rules from VLAN-based to their full predicates'.blue if @opts[:expand]
    logger.info 'Havox will switch all occurrences of Enqueue action to Output action'.blue if @opts[:output]
    @rules = Havox::Merlin.compile!(ENV['HAVOX_MERLIN_TOPOLOGY'], ENV['HAVOX_MERLIN_POLICY'], @opts)
    datapath_rules_info
  rescue => e
    handle_exception(e)
  end

  def switch_ready(dp_id)
    install_rules(dp_id)
    @datapaths << dp_id
    @datapaths_off -= [dp_id]
    dp_name = "s#{dp_id}"
    logger.info "Datapath #{dp_name.bold} is #{'ONLINE'.bold.green}"
  rescue => e
    handle_exception(e)
  end

  def switch_disconnected(dp_id)
    @datapaths -= [dp_id]
    @datapaths_off << dp_id
    dp_name = "s#{dp_id}"
    logger.info "Datapath #{dp_name.bold} is #{'OFFLINE'.bold.red}"
  end

  def packet_in(dp_id, packet_in)
    packet_details(packet_in)
  end

  private

  def datapath_statuses
    datapaths_on  = @datapaths.map { |id| "s#{id}" }.join(' ').bold.green
    datapaths_off = @datapaths_off.map { |id| "s#{id}" }.join(' ').bold.red
    logger.info "Datapath statuses: [#{datapaths_on}] [#{datapaths_off}]"
  end

  def install_rules(dp_id)
    dp_rules = @rules.select { |r| r.dp_id == dp_id }
    flow_mod_rules(dp_id, dp_rules) if dp_rules.any?
  end

  def flow_mod_rules(dp_id, dp_rules)
    dp_rules.each do |rule|
      send_flow_mod_add(
        dp_id,
        match: Pio::Match.new(rule.matches),
        actions: action_methods(rule.actions)
      )
    end
  end

  def action_methods(actions_array)
    methods = []
    actions_array.each do |obj|
      methods <<
        case obj[:action]
        when :output       then Pio::OpenFlow10::SendOutPort.new(obj[:arg_a].to_i)
        when :enqueue      then Pio::OpenFlow10::Enqueue.new(obj[:arg_a].to_i, obj[:arg_b].to_i)
        when :strip_vlan   then Pio::OpenFlow10::StripVlanHeader.new
        when :set_vlan_vid then Pio::OpenFlow10::SetVlanVid.new(obj[:arg_a].to_i)
        else raise Havox::Trema::UnpredictedAction,
          "No method associated with action '#{obj[:action]}'"
        end
    end
    methods
  end

  def datapath_rules_info
    logger.info "Generated #{@rules.size} Merlin rules:"
    @rules.group_by(&:dp_id).each do |id, rules|
      logger.info "Datapath s#{id}: #{rules.size} rule(s)"
    end
  end

  def handle_exception(e)
    puts e.message
    puts e.backtrace
  end

  def packet_details(packet_in)
    logger.info "#{packet_in.data.class.name}: dp_id=#{packet_in.dpid} " \
                "in_port=#{packet_in.in_port} src_mac=#{packet_in.source_mac} " \
                "dst_mac=#{packet_in.destination_mac} inspection=#{packet_in.inspect}"
  end

  def initialize_instance_vars
    @opts = {}
    @datapaths = []
    @datapaths_off = []
    @rules = []
  end
end
