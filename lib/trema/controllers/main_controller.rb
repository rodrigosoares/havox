class MainController < Trema::Controller
  def start(_argv)
    @datapaths = []
    logger.info 'Havox service is active.'
  end

  def switch_ready(dp_id)
    @datapaths << dp_id
    logger.info "Datapath ID #{dp_id} is online."
  end
end
