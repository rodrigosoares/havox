module HavoxRoutes
  class Configuration
    attr_accessor :protocol, :rf_host, :rf_user, :rf_password, :rf_vm_names

    def initialize
      @protocol    = ''
      @rf_host     = '192.168.1.106'
      @rf_user     = 'routeflow'
      @rf_password = 'routeflow'
      @rf_vm_names = %w(rfvmA rfvmB rfvmC rfvmD)
    end
  end
end
