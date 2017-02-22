module Havox
  class Configuration
    attr_accessor :rf_host, :rf_user, :rf_password, :rf_lxc_names, :merlin_host,
      :merlin_user, :merlin_password, :protocol_daemons

    def initialize
      @rf_host          = '10.0.30.191'
      @rf_user          = 'routeflow'
      @rf_password      = 'routeflow'
      @rf_lxc_names     = %w(rfvmA rfvmB rfvmC rfvmD)
      @merlin_host      = '10.0.33.200'
      @merlin_user      = 'frenetic'
      @merlin_password  = 'frenetic'
      @protocol_daemons = [:bgpd]
    end
  end
end
