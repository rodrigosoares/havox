4.times do |i|
  id = i + 1

  netns "h#{id}" do
    ip  "172.31.#{id}.100"
    netmask '255.255.255.0'
    route net: '0.0.0.0', gateway: "172.31.#{id}.1"
  end

  vswitch "s#{id}" do
    datapath_id id
  end

  link "h#{id}", "s#{id}"
end

link 's1', 's2'
link 's1', 's3'
link 's1', 's4'
link 's2', 's4'
link 's3', 's4'
