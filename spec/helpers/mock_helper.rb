module MockHelper
  def merlin_response(empty = false)
    "\nMax map:\nMin map:\nv1 -> 11111111\n\nGraph construction time:\t858010" \
    "\nObjective construction time:\t120355\nConst construction time:\t258465" \
    "\nBounds construction time:\t10624\nLP construction time:\t476983\nLP wr" \
    "ite time:\t216309\nGurobi time:\t360356240\nVariables:\t14\n\nHop and ed" \
    "ge mappings for paths:\n\nEdge: v2 Statement: v1 Hop: Ingress\nEdge: v3 " \
    "Statement: v1 Hop: Egress\n\nOpenFlow rules (1):#{openflow_rules(empty)}" \
    "\n\nQueue Configurations (1):\n\nOn switch 1:\n\tOn port 1:\n\t\t1 -> 11" \
    "111111 1111111111111111117\n\n\ntc Configurations (0):\n\n\n\ntc Clicks " \
    "(0):\n\n\n"
  end

  def merlin_error_response
    "Uncaught exception:\n\nParsing.Parse_error\n\nRaised at file \"parsing.m" \
    "l\", line 138, characters 14-25\nCalled from file \"parsing.ml\", line 1" \
    "64, characters 4-28\nRe-raised at file \"parsing.ml\", line 183, charact" \
    "ers 14-17\nCalled from file \"lib/Merlin_FrontEnd.ml\", line 36, charact" \
    "ers 2-40"
  end

  def raw_rule
    '(((switch = 1 and (* and (ethTyp = 2048 and ipDst = 167772162) and '      \
    'ipSrc = 167772161) and port = 80)) and vlanId = 65535) -> Enqueue(0, 2) ' \
    'Output(0)'
  end

  def conflicting_raw_rule
    '(((switch = 1 and (* and (ethTyp = 2048 and ipDst = 167772162) and '      \
    'and nwProto = 17 and ipSrc = 167772161) and nwProto = 6 and port = 80)) ' \
    'and vlanId = 65535) -> Enqueue(0, 2) Output(0)'
  end

  def topology_file_content
    "digraph g1 {\n  h1 [type = host];\n  h2 [type = host];\n}\n"
  end

  def policy_file_content
    "all := { h1; h2 };\nforeach (s, d): cross(all, all)\n  ipProto = 6 -> .*" \
    " at min(100 Mbps);\n"
  end

  private

  def openflow_rules(empty)
    unless empty
      "\n\nOn switch 1\t(((switch = 1\n  and (port = 0 and (((ipSrc = 1000000" \
      "01 and ipDst = 100000002)) and *))))\nand vlanId = 10000) -> SetField(" \
      "vlan, 1)\tEnqueue(1,1)"
    end
  end
end
