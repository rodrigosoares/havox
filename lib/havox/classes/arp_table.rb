class Havox::ARPTable
  def initialize
    @table = {}
  end

  def lookup(mac)
    entry = @table[mac]
    entry&.port
  end

  def learn!(mac, port)
    entry = @table[mac]
    if entry
      entry.update!(port)
    else
      @table[mac] = Havox::ARPEntry.new(mac, port)
    end
  end

  def age!
    @table.delete_if { |_mac, entry| entry.aged? }
  end
end
