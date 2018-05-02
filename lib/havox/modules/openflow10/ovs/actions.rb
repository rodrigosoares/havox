module Havox
  module OpenFlow10
    module OVS
      module Actions
        extend Havox::FieldParser

        def self.treat(actions_array, opts = {})
          of_actions = []
          actions_array.each do |obj|
            of_actions <<
              case obj[:action]
              when 'Output' then basic_action(:output, obj[:arg_a])
              when 'Enqueue' then output_or_enqueue(obj, opts[:output])
              when 'SetField' then basic_action_from_set_field(obj)
              when 'Drop' then basic_action(:drop)
              else raise_unknown_action(obj)
              end
          end
          of_actions
        end

        private

        def self.basic_action_from_set_field(obj)
          if obj[:arg_a].eql?('vlan')
            obj[:arg_b].eql?('<none>') ? basic_action(:strip_vlan) : basic_action(:mod_vlan_vid, obj[:arg_b])
          else
            raise_unknown_action(obj)
          end
        end

        def self.output_or_enqueue(obj, change_to_output)
          if change_to_output
            basic_action(:output, obj[:arg_a])
          else
            basic_action(:enqueue, obj[:arg_a], obj[:arg_b])
          end
        end
      end
    end
  end
end
