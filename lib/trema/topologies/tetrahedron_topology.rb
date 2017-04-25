4.times do |i|
  id = i + 1

  netns "h#{id}" do
    ip  "10.0.0.#{id * 10}"
    netmask '255.255.255.0'
    route net: '0.0.0.0', gateway: '10.0.0.1'
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
