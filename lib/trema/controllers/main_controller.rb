require 'havox'
require 'colorize'

class MainController < Trema::Controller
  def start(_argv)
    logger.info "Havox service is #{'ACTIVE'.bold}."
    logger.info "Generating rules based on the policies defined in #{ENV['MERLIN_POLICY'].bold}" \
                " over the topology #{ENV['MERLIN_TOPOLOGY'].bold}..."
    @rules = Havox::Policies.compile!(ENV['MERLIN_TOPOLOGY'], ENV['MERLIN_POLICY'])
    logger.info "Generated #{@rules.size} Merlin rules."
    @datapaths = []
  end

  def switch_ready(dp_id)
    @datapaths << dp_id
    dp_name = "s#{dp_id}"
    logger.info "Datapath #{dp_name.bold} is #{'ONLINE'.bold.green}."
  end
end
