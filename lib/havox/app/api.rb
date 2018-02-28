require 'bundler/setup' # TODO: Remove this line after Havox is released to RubyGems.
require 'sinatra'
require 'colorize'
require 'havox'
require_relative '../../../config'
require_relative 'helpers/methods'

module Havox
  class API < Sinatra::Base
    set :bind, '0.0.0.0'

    before { content_type :json }

    # TODO: Make this read files from anywhere in the file system.
    get '/rules/:name' do
      base_dir = '/home/rod/Projetos/Mestrado/havox/lib/merlin'
      opts = {
        merlin_topology: "#{base_dir}/topologies/#{params[:name]}.dot",
        merlin_policy: "#{base_dir}/policies/#{params[:name]}.mln",
        force: params[:force].eql?('true'),
        basic: params[:basic].eql?('true'),
        expand: params[:expand].eql?('true'),
        output: params[:output].eql?('true'),
        syntax: params[:syntax]&.to_sym
      }
      Havox::Policy.new(opts).to_json
    end

    post '/rules' do
      dot_filepath = handle_file(params[:dot_file])
      hvx_filepath = handle_file(params[:hvx_file])
      pre_opts = {
        qos: params[:qos],
        preferred: params[:preferred],
        arbitrary: params[:arbitrary]
      }
      mln_filepath = run_network(dot_filepath, hvx_filepath, pre_opts)

      if mln_filepath.nil?
        [].to_json
      else
        pos_opts = {
          merlin_topology: dot_filepath,
          merlin_policy: mln_filepath,
          force: params[:force].eql?('true'),
          basic: params[:basic].eql?('true'),
          expand: params[:expand].eql?('true'),
          output: params[:output].eql?('true'),
          syntax: params[:syntax]&.to_sym
        }
        policy = Havox::Policy.new(pos_opts)
        print_policy(policy, pos_opts)
        policy.to_json
      end
    end
  end
end
