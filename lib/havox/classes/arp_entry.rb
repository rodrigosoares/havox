class Havox::ARPEntry
  attr_reader :mac, :port

  MAX_AGE = 300

  def initialize(mac, port, max_age = MAX_AGE)
    @mac = mac
    @port = port
    @max_age = max_age
    @updated_at = Time.now
  end

  def update!(port)
    @port = port
    @updated_at = Time.now
  end

  def aged?
    Time.now - @updated_at > @max_age
  end
end
