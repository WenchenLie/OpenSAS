import openseespy.opensees as ops

def Spring_Zero(SpringID, NodeI, NodeJ):
    # ops.element("zeroLength", SpringID, NodeI, NodeJ, "-mat", 99, 99, 9, "-dir", 1, 2, 6)
    # ops.element("zeroLength", SpringID, NodeI, NodeJ, "-mat", 9, "-dir", 6)
    ops.equalDOF(NodeI, NodeJ, 1, 2)
