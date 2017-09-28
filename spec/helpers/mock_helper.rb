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
    "digraph g1 {\n"\
    "  h1 [type = host, ip = \"10.0.0.1\"];\n" \
    "  h2 [type = host, ip = \"10.0.0.2\"];\n" \
    "  s1 [type = switch, ip = \"10.0.0.3\"];\n" \
    "  s1 -> h1 [src_port = 1, dst_port = 1];\n" \
    "  h1 -> s1 [src_port = 1, dst_port = 1];\n" \
    "  s1 -> h2 [src_port = 2, dst_port = 1];\n" \
    "  h2 -> s1 [src_port = 1, dst_port = 2];\n" \
    "}\n"
  end

  def topo_2h_2sw_content
    "digraph g1 {\n"\
    "  h1 [type = host, ip = \"172.31.1.100\"];\n" \
    "  h2 [type = host, ip = \"172.31.2.100\"];\n" \
    "  s1 [type = switch, ip = \"172.31.1.1\", id = 1];\n" \
    "  s2 [type = switch, ip = \"172.31.2.1\", id = 2];\n" \
    "  s1 -> h1 [src_port = 1, dst_port = 1];\n" \
    "  h1 -> s1 [src_port = 1, dst_port = 1];\n" \
    "  s2 -> h2 [src_port = 1, dst_port = 1];\n" \
    "  h2 -> s2 [src_port = 1, dst_port = 1];\n" \
    "  s1 -> s2 [src_port = 2, dst_port = 2];\n" \
    "  s2 -> s1 [src_port = 2, dst_port = 2];\n" \
    "}\n"
  end

  def policy_file_content
    "all := { h1; h2 };\nforeach (s, d): cross(all, all)\n  ipProto = 6 -> .*" \
    " at min(100 Mbps);\n"
  end

  def container_ospf_routes_response
    "Codes: K - kernel route, C - connected, S - static, R - RIP, O - OSPF,\n" \
    "       I - ISIS, B - BGP, > - selected route, * - FIB route\n\nO>* 10.0." \
    "0.0/24 [110/20] via 40.0.0.2, eth2, 03:41:18\n  *                      v" \
    "ia 50.0.0.1, eth4, 03:41:18\nO   20.0.0.0/24 [110/10] is directly connec" \
    "ted, eth3, 03:41:39\nO>* 30.0.0.0/24 [110/20] via 20.0.0.3, eth3, 03:41:" \
    "18\n  *                      via 50.0.0.1, eth4, 03:41:18\nO   40.0.0.0/" \
    "24 [110/10] is directly connected, eth2, 03:41:39\nO   50.0.0.0/24 [110/" \
    "10] is directly connected, eth4, 03:41:39\nO>* 172.31.1.0/24 [110/20] vi" \
    "a 50.0.0.1, eth4, 03:41:18\nO>* 172.31.2.0/24 [110/20] via 40.0.0.2, eth" \
    "2, 03:41:26\nO>* 172.31.3.0/24 [110/20] via 20.0.0.3, eth3, 03:41:26\nO " \
    "  172.31.4.0/24 [110/10] is directly connected, eth1, 03:41:39\n"
  end

  private

  def openflow_rules(empty)
    unless empty
      "\n\nOn switch 1\t(((switch = 1\n  and (port = 0 and (((ipSrc = 1000000" \
      "01 and ipDst = 100000002)) and *))))) -> SetField(vlan, 1)\tEnqueue(1,1)"
    end
  end
end
