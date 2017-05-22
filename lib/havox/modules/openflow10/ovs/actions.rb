module Havox
  module OpenFlow10
    module OVS
      module Actions
        extend Havox::FieldParser

        def self.treat(actions_array)
          of_actions = []
          actions_array.each do |obj|
            of_actions <<
              case obj[:action]
              when 'Output' then basic_action(:output, obj[:arg_a])
              when 'Enqueue' then basic_action(:enqueue, obj[:arg_a], obj[:arg_b])
              when 'SetField' then basic_action_from_set_field(obj)
              else raise_unknown_action(obj)
              end
          end
          of_actions
        end
      end
    end
  end
end
