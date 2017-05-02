require 'havox'
require 'colorize'

class MainController < Trema::Controller
  timer_event :datapath_statuses, interval: 10.sec
  timer_event :age_arp_tables, interval: 5.sec

  def start(_argv)
    initialize_instance_vars
    logger.info "Generating rules based on the policies defined in #{ENV['HAVOX_MERLIN_POLICY'].bold}" \
                " over the topology #{ENV['HAVOX_MERLIN_TOPOLOGY'].bold}..."
    force = ENV['HAVOX_FORCE'].eql?('true')
    @rules = Havox::Policies.compile!(ENV['HAVOX_MERLIN_TOPOLOGY'], ENV['HAVOX_MERLIN_POLICY'], force)
    datapath_rules_info
  rescue => e
    handle_exception(e)
  end

  def switch_ready(dp_id)
    @arp_tables[dp_id] = Havox::ARPTable.new
    @datapaths << dp_id
    @datapaths_off -= [dp_id]
    dp_name = "s#{dp_id}"
    logger.info "Datapath #{dp_name.bold} is #{'ONLINE'.bold.green}"
    install_rules(dp_id)
  rescue => e
    handle_exception(e)
  end

  def switch_disconnected(dp_id)
    @arp_tables.delete(dp_id)
    @datapaths -= [dp_id]
    @datapaths_off << dp_id
    dp_name = "s#{dp_id}"
    logger.info "Datapath #{dp_name.bold} is #{'OFFLINE'.bold.red}"
  end

  def packet_in(dp_id, packet_in)
    return if packet_in.destination_mac.reserved? || packet_in.destination_mac.multicast?
    logger.info "in_port = #{packet_in.in_port}, src_mac = #{packet_in.source_mac}, " \
                "dst_mac = #{packet_in.destination_mac}, dp_id = #{packet_in.dpid}"
    @arp_tables[dp_id].learn!(packet_in.source_mac, packet_in.in_port)
    flow_mod_and_packet_out(packet_in)
  end

  private

  def datapath_statuses
    datapaths_on  = @datapaths.map { |id| "s#{id}" }.join(' ').bold.green
    datapaths_off = @datapaths_off.map { |id| "s#{id}" }.join(' ').bold.red
    logger.info "Datapath statuses: [#{datapaths_on}] [#{datapaths_off}]"
  end

  def flow_mod_and_packet_out(packet_in)
    port = @arp_tables[packet_in.dpid].lookup(packet_in.destination_mac)
    flow_mod(packet_in, port) unless port.nil?
    packet_out(packet_in, port || :flood)
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
        # when :enqueue      then Pio::OpenFlow10::Enqueue.new(obj[:arg_a].to_i, obj[:arg_b].to_i)
        when :enqueue      then Pio::OpenFlow10::SendOutPort.new(obj[:arg_a].to_i)
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

  def flow_mod(packet_in, port)
    send_flow_mod_add(
      packet_in.dpid,
      match: Pio::ExactMatch.new(packet_in),
      actions: Pio::OpenFlow10::SendOutPort.new(port)
    )
  end

  def packet_out(packet_in, port)
    send_packet_out(
      packet_in.dpid,
      packet_in: packet_in,
      actions: Pio::OpenFlow10::SendOutPort.new(port)
    )
  end

  def age_arp_tables
    @arp_tables.each_value(&:age!)
  end

  def handle_exception(e)
    puts e.message
    puts e.backtrace
  end

  def initialize_instance_vars
    @datapaths = []
    @datapaths_off = []
    @rules = []
    @arp_tables = {}
  end
end
