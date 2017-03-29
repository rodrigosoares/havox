require 'havox'

class MainController < Trema::Controller
  def start(_argv)
    @datapaths = []
    logger.info 'Havox service is ACTIVE.'
    logger.info "Using Merlin topology from #{ENV['MERLIN_TOPOLOGY']}."
    logger.info "Using Merlin policy from #{ENV['MERLIN_POLICY']}."
    @rules = Havox::Policies.compile!(ENV['MERLIN_TOPOLOGY'], ENV['MERLIN_POLICY'])
    logger.info "The number of generated Merlin rules is #{@rules.size}"
  end

  def switch_ready(dp_id)
    @datapaths << dp_id
    logger.info "Datapath s#{dp_id} is ONLINE."
  end
end
