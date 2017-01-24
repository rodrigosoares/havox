module Havox
  class Configuration
    attr_accessor :rf_host, :rf_user, :rf_password, :rf_lxc_names,
      :protocol_daemons

    def initialize
      @rf_host          = '192.168.1.106'
      @rf_user          = 'routeflow'
      @rf_password      = 'routeflow'
      @rf_lxc_names     = %w(rfvmA rfvmB rfvmC rfvmD)
      @protocol_daemons = [:bgpd]
    end
  end
end
