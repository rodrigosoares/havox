4.times do |i|
  id = i + 1

  vhost "h#{id}" do
    ip  "10.0.0.#{id}"
    mac "00:00:00:00:00:#{id}"
  end

  vswitch "s#{id}" do
    datapath_id id
  end

  link "h#{id}", "s#{id}"
end

link 's1', 's2'
link 's1', 's3'
link 's1', 's4'
link 's2', 's3'
link 's2', 's4'
link 's3', 's4'
