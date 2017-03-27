6.times do |i|
  id = i + 1

  vhost "h#{id}" do
    ip  "10.0.0.#{id}"
    mac "00:00:00:00:00:#{id}"
  end

  vswitch "s#{id}" do
    datapath_id id
    # ip "11.0.0.#{id}"
  end

  link "h#{id}", "s#{id}"
end

%w(20 60).each do |id|
  vhost "h#{id}" do
    ip  "10.0.0.#{id}"
    mac "00:00:00:00:00:#{id}"
  end

  link "h#{id}", "s#{id.to_i / 10}"
end

link 's1', 's2'
link 's1', 's3'
link 's2', 's3'
link 's2', 's4'
link 's3', 's4'
link 's3', 's5'
link 's4', 's6'
link 's5', 's6'
