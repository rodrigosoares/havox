require 'havox'
require 'colorize'

class MainController < Trema::Controller
  timer_event :datapath_statuses, interval: 10.sec

  def start(_argv)
    @datapaths = []
    @datapaths_off = []
    logger.info "Generating rules based on the policies defined in #{ENV['MERLIN_POLICY'].bold}" \
                " over the topology #{ENV['MERLIN_TOPOLOGY'].bold}..."
    @rules = Havox::Policies.compile!(ENV['MERLIN_TOPOLOGY'], ENV['MERLIN_POLICY'])
    datapath_rules_info
  rescue => e
    @rules = []
    handle_exception(e)
  end

  def switch_ready(dp_id)
    @datapaths << dp_id
    @datapaths_off -= [dp_id]
    dp_name = "s#{dp_id}"
    logger.info "Datapath #{dp_name.bold} is #{'ONLINE'.bold.green}"
    install_rules(dp_id)
  rescue => e
    handle_exception(e)
  end

  def switch_disconnected(dp_id)
    @datapaths -= [dp_id]
    @datapaths_off << dp_id
    dp_name = "s#{dp_id}"
    logger.info "Datapath #{dp_name.bold} is #{'OFFLINE'.bold.red}"
  end

  private

  def datapath_statuses
    datapaths_on  = @datapaths.map { |id| "s#{id}" }.join(' ').bold.green
    datapaths_off = @datapaths_off.map { |id| "s#{id}" }.join(' ').bold.red
    logger.info "Datapath statuses: [#{datapaths_on}] [#{datapaths_off}]"
  end

  def install_rules(dp_id)
    dp_rules = @rules.select { |r| r.dp_id == dp_id }
    flow_mod(dp_id, dp_rules) if dp_rules.any?
  end

  def flow_mod(dp_id, dp_rules)
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

  def handle_exception(e)
    puts e.message
    puts e.backtrace
  end
end
