# Havox

Havox is a rule generator for Autonomous Systems supported by OpenFlow switches. Based on orchestration directives (or instructions) written in its own configuration language, Havox generates a set of OpenFlow rules to be installed on the underlying switches.

As part of a bigger architecture, Havox is designed to run as a web API that receives requests containing the directives, the topology graph description and some parameters for rule formatting. Once the rules are generated, the API responds with a JSON message containing all the rules, each one indicating which OpenFlow switch it should be installed on.

The mentioned architecture is composed of Havox, [RouteFlow](https://github.com/routeflow/RouteFlow) and [Merlin](https://github.com/merlin-lang/merlin), and currently tested in a [Mininet](https://github.com/mininet/mininet) environment with support of [MiniNext](https://github.com/USC-NSL/miniNExT) implementing Quagga routing engines. RouteFlow requests rules from Havox and therefore is a client, whereas Merlin is a dependency which effectively calculates the paths between the AS exits.

## Development status

Havox is still experimental, born from a [master's thesis](http://www2.uniriotec.br/ppgi/banco-de-dissertacoes-ppgi-unirio/ano-2017/havox-uma-arquitetura-para-orquestracao-de-trafego-em-redes-openflow/view), so it is being actively developed and improved. There is yet a lot of new functionalities to come.

If you want to check how it works, there's a [video tutorial in YouTube](https://youtu.be/Rtj7AjH5V6U) that shows how to set it up and run.

## How it works

Havox is implemented in Ruby and is strongly based on metaprogramming concepts. The orchestration directives that forms its configuration language are methods executed by the Ruby interpreter, having both values and entire blocks of code as parameters. The following code shows some Havox directives:

```ruby
topology 'example.dot'
associate :rfvmE, :s5

exit(:s4) { destination_port 80 }
exit(:s3) {
  source_ip '200.156.0.0/16'
  destination_ip '200.20.0.0/16'
}

tunnel(:s1, :s4) { source_port 443 }
circuit(:s2, :s4, :s3) { destination_port 3306 }
```

The first one, `topology <file_name>` is a topology file definition directive. It takes a string and specifies the topology description file that should be considered, which usually goes together with the directives file in the same request.

The second, `associate <router_name>, <switch_name>` is the router-switch association directive. It takes a string or a [symbol](https://ruby-doc.org/core-2.4.0/Symbol.html) that specifies the RouteFlow container name that runs the target routing instance and its associated OpenFlow switch name. In this case, it associates the routing container _rfvmE_ to the switch _s5_.

Next, there are two orchestration directives that instructs the matching flow to leave the network by the indicated switch. The exit directive, `exit(<switch_name>) { <openflow_fields_and_values> }`, takes the switch name as a string or symbol and a block containing the supported OpenFlow fields and their respective matching values, which can be strings or integers depending on the field.

For example, the first `exit` directive tells that any matching traffic with destination port 80 should leave the domain by the switch _s4_. The second `exit` directive tells that any packet that comes from the network 200.156/16 and heads to the network 200.20/16 must leave the domain by the switch _s3_.

The tunnel directive, `tunnel(<inbound_switch_name>, <outbound_switch_name>) { <openflow_fields_and_values> }`, instructs matching packets that ingress the domain by the specified inbound switch to leave it through the specified outbound switch.

The circuit directive, `circuit(<switch_names>) { <openflow_fields_and_values> }`, is similar to the tunnel directive, but the matching packets will flow through the specified path of switches, separated by commas. The path must be possible at the topology level, or an exception will be raised. In the example, matching packets ingressing by _s2_ must pass through _s4_ and then through _s3_ in order to leave the network.

The topology file is a graph description file written in [DOT language](https://en.wikipedia.org/wiki/DOT_(graph_description_language)) and describes how the network topology is organized. This file is processed by both Havox and its dependency, Merlin. Each node has informations like its name, its internal IP address from one of its interfaces and how it is connected to the other nodes. It is important to know that this IP address is used by Havox to infer the associations between routing containers and switches using OSPF routes. Otherwise, it would be required to manually associate each pair using the association directive described above.

The exit directives from the request will be transcompiled to Merlin blocks of code, written in a Merlin policy file. This file is sent with the topology file to the Merlin process, where they will be evaluated for paths calculation. The generated raw rules are then post-processed, formatted and outputted by the API.

More details about the transcompilation, parsing and formatting processes can be found [here](http://www2.uniriotec.br/ppgi/banco-de-dissertacoes-ppgi-unirio/ano-2017/havox-uma-arquitetura-para-orquestracao-de-trafego-em-redes-openflow/view) (master's thesis in brazilian portuguese).

## Installation

Install Havox by:

1. Cloning the repository: `$ git clone https://github.com/rodrigosoares/havox`
2. Accessing the directory: `$ cd havox`
3. Installing gem dependencies: `$ bin/setup`

Besides, Havox requires [Merlin](https://github.com/merlin-lang/merlin) and a [modified version of RouteFlow](https://github.com/rodrigosoares/RouteFlow) that implements IP source and VLAN ID matching, subnet mask support and RFHavox module. The latter is an extra RouteFlow module designed to request rules from the remote Havox web API and enqueue them into the RouteFlow IPC system.

If the tests will be run in a experimental network, [Mininet](https://github.com/mininet/mininet) and [MiniNext](https://github.com/USC-NSL/miniNExT) are also required. Gists containing example Quagga BGP configurations and Mininet topology files can be found [here](https://gist.github.com/rodrigosoares/53ca13f0376ade1fa7b7221328dae3ce).

It is *strongly recommended* to install Merlin, RouteFlow and Mininet/MiniNext in isolated virtual machines, each. Make sure that all the VMs ping each other successfully. The recommendation is to use [VirtualBox](https://www.virtualbox.org/) with _host-only network_ adapters.

Setup all projects following their respective installation instructions. If using RouteFlow with Mininet, follow the [instructions](https://github.com/routeflow/RouteFlow/wiki/Tutorial-2:-rftest2) on setting Mininet up with RouteFlow remote controller.

## Usage

HVX, MN and RF are the environments running Havox, Mininet and RouteFlow, respectively.

1. (HVX) Setup Merlin and RouteFlow IPs and etcetera in `config.rb`.
2. (HVX) Start Havox API web server: `$ bundle exec havox`.
3. (MN) Start Mininet, pointing its remote controller to the RouteFlow VM.
4. (RF) Start RouteFlow (e.g.: _example_2x2_): `sudo ./rftest/example_2x2`.

If everything runs fine, RouteFlow will send a POST request to Havox, which in turn will log it and respond.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rspec --format d` to run the tests and read a little documentation about what each component does. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rodrigosoares/havox.

Be sure to follow [Ruby best practices](https://github.com/bbatsov/ruby-style-guide) and to create a spec test case for each new method, module or component you create.

## License

The gem is available as open source under the terms of the [GPL 3.0 License](https://opensource.org/licenses/GPL-3.0).
