module Havox
  module OpenFlow10
    module Actions
      def self.syntax_treated(actions_array)
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

      private

      def self.basic_action(action, arg_a = nil, arg_b = nil)
        { action: action, arg_a: arg_a, arg_b: arg_b }
      end

      def self.basic_action_from_set_field(obj)
        if obj[:arg_a].eql?('vlan')
          obj[:arg_b].eql?('<none>') ? basic_action(:strip_vlan) : basic_action(:set_vlan_vid, obj[:arg_b])
        else
          raise_unknown_action(obj)
        end
      end

      def self.raise_unknown_action(obj)
        raise Havox::Trema::UnpredictedAction,
          "Unable to translate action #{obj[:action]} with arguments A:"       \
          " #{obj[:arg_a]} and B: #{obj[:arg_b]}, respectively"
      end
    end
  end
end
