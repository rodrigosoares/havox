# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'havox/version'

Gem::Specification.new do |spec|
  spec.name          = 'havox'
  spec.version       = Havox::VERSION
  spec.authors       = ['Rodrigo Soares']
  spec.email         = ['silvars1@gmail.com']

  spec.summary       = %q{This gem parses the RIBs from RouteFlow VMs.}
  spec.description   = %q{This gem parses the RIBs from RouteFlow VMs.}
  spec.homepage      = 'https://github.com/rodrigosoares/havox'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = 'havox'
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.11.2'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'factory_girl', '~> 4.8.0'
  spec.add_development_dependency 'awesome_print', '~> 1.7.0'
  spec.add_runtime_dependency     'net-ssh', '~> 4.0.0'
  spec.add_runtime_dependency     'net-scp', '~> 1.2.1'
  spec.add_runtime_dependency     'trema', '~> 0.10'
  spec.add_runtime_dependency     'colorize', '~> 0.8.1'
end
