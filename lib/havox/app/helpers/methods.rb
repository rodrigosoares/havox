helpers do
  def handle_file(params)
    filepath = "./#{params[:filename]}"
    File.open(filepath, 'w') { |f| f.write(params[:tempfile].read) }
    filepath
  end

  def run_network(dot_filepath, hvx_filepath, opts = {})
    mln_filename = "./#{File.basename(hvx_filepath, '.hvx')}.mln"
    eval File.read(hvx_filepath)
    mln_blocks = Havox::Network.transcompile(opts)
    print_blocks(mln_blocks, opts)
    return nil if mln_blocks.empty?
    File.open(mln_filename, 'w') { |f| f.write(mln_blocks.join("\n")) }
    mln_filename
  end

  def print_blocks(merlin_blocks, opts)
    print_opts(opts)
    if merlin_blocks.empty?
      puts 'No Merlin code was generated'.bold.red
    else
      puts 'Merlin code generated:'.bold
      puts merlin_blocks.join("\n").green
    end
  end

  def print_policy(policy, opts)
    print_opts(opts)
    puts "Generated #{policy.rules.size} rule(s)".bold
  end

  def print_opts(opts)
    puts 'Havox will:'.bold
    puts "- generate Merlin code with QoS '#{opts[:qos]}'".blue unless opts[:qos].nil?
    puts "- generate Merlin code with preference for exit switches: #{opts[:preferred].join(', ')}".blue unless opts[:preferred].nil?
    puts "- generate Merlin code with arbitrary exit switches: #{opts[:arbitrary].join(', ')}".blue unless opts[:arbitrary].nil?
    puts '- force attribute redefinition for rules with an attribute defined twice'.blue if opts[:force]
    puts '- automatically append policies for ARP and ICMP protocols'.blue if opts[:basic]
    puts '- expand generated rules from VLAN-based to their full predicates'.blue if opts[:expand]
    puts '- switch all occurrences of Enqueue action to Output action'.blue if opts[:output]
  end
end
