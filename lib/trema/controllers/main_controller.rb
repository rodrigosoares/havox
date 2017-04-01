require 'havox'
require 'colorize'

class MainController < Trema::Controller
  timer_event :datapath_statuses, interval: 10.sec

  def start(_argv)
    logger.info "Generating rules based on the policies defined in #{ENV['MERLIN_POLICY'].bold}" \
                " over the topology #{ENV['MERLIN_TOPOLOGY'].bold}..."
    @rules = Havox::Policies.compile!(ENV['MERLIN_TOPOLOGY'], ENV['MERLIN_POLICY'])
    logger.info "Generated #{@rules.size} Merlin rules."
    @datapaths = []
    @datapaths_off = []
  end

  def switch_ready(dp_id)
    @datapaths << dp_id
    @datapaths_off -= [dp_id]
    dp_name = "s#{dp_id}"
    logger.info "Datapath #{dp_name.bold} is #{'ONLINE'.bold.green}."
    install_rules(dp_id)
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
    # code
  end
end
