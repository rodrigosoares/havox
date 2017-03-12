module MockHelper
  def merlin_response
    "\nMax map:\nMin map:\nv1 -> 11111111\n\nGraph construction time:\t858010" \
    "\nObjective construction time:\t120355\nConst construction time:\t258465" \
    "\nBounds construction time:\t10624\nLP construction time:\t476983\nLP wr" \
    "ite time:\t216309\nGurobi time:\t360356240\nVariables:\t14\n\nHop and ed" \
    "ge mappings for paths:\n\nEdge: v2 Statement: v1 Hop: Ingress\nEdge: v3 " \
    "Statement: v1 Hop: Egress\n\nOpenFlow rules (1):\n\nOn switch 1\t(((swit" \
    "ch = 1\n  and (port = 0 and (((ipSrc = 100000001 and ipDst = 100000002))" \
    " and *))))\nand vlanId = 10000) -> Enqueue(1,1)\n\nQueue Configurations " \
    "(1):\n\nOn switch 1:\n\tOn port 1:\n\t\t1 -> 11111111 111111111111111111" \
    "7\n\n\ntc Configurations (0):\n\n\n\ntc Clicks (0):\n\n\n"
  end

  def raw_rule
    '(((switch = 1 and (* and (ethTyp = 2048 and ipDst = 167772162) and ' \
    'ipSrc = 167772161) and port = 80)) and vlanId = 65535) -> Output(0)'
  end
end
