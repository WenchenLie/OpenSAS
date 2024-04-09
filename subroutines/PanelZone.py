# -------------------------- Construct panel zone model --------------------------
#
# Args (16):
# ---------------
# Floor          FLoor number
# Axis           Axis number
# X, Y           Coordiate of panel zone center
# E              Young's modulus
# mu             Possion ration
# fy             Yield strength
# A_stiff        Cross section area of rigid link
# I_stiff        Moment of inertia of rigid link
# d_col          Column section depth
# d_beam         Beam section depth
# tp             Panel zone thickness (column web + doubler plate)
# tf             Column flange thickness
# bf             Column flange width
# transfTag      Geometric transformation ID
# type_          Modeling approach (1: Parallelogram, 2: Cruciform)
# position       Panel zone position
#                   I: Internal
#                   L: Left
#                   R: Right
#                   T: top
#                   LT: Left top
#                   RT: Right top
# check          Print Hysteretic model parameters
# 
# ---------------
# Written by: Wenchen Lie, Guangzhou University, China
# Date: 2024-03-26
# --------------------------------------------------------------------------------

import openseespy.opensees as ops
from typing import Literal


def PanelZone(
    Floor: int, Axis: int,
    X: float, Y: float,
    E: float, mu: float, fy: float,
    A_stiff: float, I_stiff: float,
    d_col: float, d_beam: float, tp: float, tf: float,
    bf: float, transfTag: Literal[1, 2, 3],
    type_: Literal[1, 2],
    position: Literal['L', 'T', 'LT', 'RT'], check: bool=None):
    # node ID
    node_C = 11000000 + Floor * 10000 + Axis * 100  # 11FFAA01
    node_B = node_C + 1  # 11FFAA01
    node_L = node_C + 2  # 11FFAA02
    node_T = node_C + 3  # 11FFAA03
    node_R = node_C + 4  # 11FFAA04
    node_BL = node_C + 5  # 11FFAA05
    node_LB = node_C + 6  # 11FFAA06
    node_LT = node_C + 7  # 11FFAA07
    node_TL = node_C + 8  # 11FFAA08
    node_TR = node_C + 9  # 11FFAA09
    node_RT = node_C + 10  # 11FFAA10
    node_RB = node_C + 11  # 11FFAA11
    node_BR = node_C + 12  # 11FFAA12

    # Construct nodes
    if type_ == 1:
        ops.node(node_B, X, Y - 0.5 * d_beam)
        ops.node(node_R, X + 0.5 * d_col, Y)
        ops.node(node_T, X, Y + 0.5 * d_beam)
        ops.node(node_L, X - 0.5 * d_col, Y)
    elif type_ == 2:
        ops.node(node_B, X, Y - 0.5 * d_beam)
        ops.node(node_R, X + 0.5 * d_col, Y)
        if type_ != "L" and type_ != "LT":
            ops.node(node_L, X - 0.5 * d_col, Y)
        if type_ != "T" and type_ != "LT" and type_ != "RT":
            ops.node(node_T, X, Y + 0.5 * d_beam)
    if type_ == 1:
        ops.node(node_BL, X - 0.5 * d_col, Y - 0.5 * d_beam)
        ops.node(node_LB, X - 0.5 * d_col, Y - 0.5 * d_beam)
        ops.node(node_LT, X - 0.5 * d_col, Y + 0.5 * d_beam)
        ops.node(node_TL, X - 0.5 * d_col, Y + 0.5 * d_beam)
        ops.node(node_TR, X + 0.5 * d_col, Y + 0.5 * d_beam)
        ops.node(node_RT, X + 0.5 * d_col, Y + 0.5 * d_beam)
        ops.node(node_RB, X + 0.5 * d_col, Y - 0.5 * d_beam)
        ops.node(node_BR, X + 0.5 * d_col, Y - 0.5 * d_beam)
    elif type_ == 2:
        ops.node(node_C, X, Y)

    # Rigid elements ID
    ele_B = 11000000 + Floor * 10000 + Axis * 100 + 1
    ele_L = ele_B + 1
    ele_T = ele_B + 2
    ele_R = ele_B + 3
    ele_BL = 11000000 + Floor * 10000 + Axis * 100 + 1
    ele_LB = ele_BL + 1
    ele_LT = ele_BL + 2
    ele_TL = ele_BL + 3
    ele_TR = ele_BL + 4
    ele_RT = ele_BL + 5
    ele_RB = ele_BL + 6
    ele_BR = ele_BL + 7

    # Construct rigid elements
    if type_ == 1:
        ops.element("elasticBeamColumn", ele_BL, node_B, node_BL, A_stiff, E, I_stiff, transfTag)
        ops.element("elasticBeamColumn", ele_LB, node_LB, node_L, A_stiff, E, I_stiff, transfTag)
        ops.element("elasticBeamColumn", ele_LT, node_L, node_LT, A_stiff, E, I_stiff, transfTag)
        ops.element("elasticBeamColumn", ele_TL, node_TL, node_T, A_stiff, E, I_stiff, transfTag)
        ops.element("elasticBeamColumn", ele_TR, node_T, node_TR, A_stiff, E, I_stiff, transfTag)
        ops.element("elasticBeamColumn", ele_RT, node_RT, node_R, A_stiff, E, I_stiff, transfTag)
        ops.element("elasticBeamColumn", ele_RB, node_R, node_RB, A_stiff, E, I_stiff, transfTag)
        ops.element("elasticBeamColumn", ele_BR, node_BR, node_B, A_stiff, E, I_stiff, transfTag)
    elif type_ == 2:
        ops.element("elasticBeamColumn", ele_B, node_C, node_B, A_stiff, E, I_stiff, transfTag)
        ops.element("elasticBeamColumn", ele_R, node_C, node_R, A_stiff, E, I_stiff, transfTag)
        if position != "L" and position != "LT":
            ops.element("elasticBeamColumn", ele_L, node_C, node_L, A_stiff, E, I_stiff, transfTag)
        if position != "T" and position != "LT" and position != "RT":
            ops.element("elasticBeamColumn", ele_T, node_C, node_T, A_stiff, E, I_stiff, transfTag)

    # Restrain DOF at panel corners
    if type_ == 1:
        ops.equalDOF(node_RB, node_BR, 1, 2)
        ops.equalDOF(node_BL, node_LB, 1, 2)
        ops.equalDOF(node_LT, node_TL, 1, 2)
        ops.equalDOF(node_TR, node_RT, 1, 2)

    # Calculating shear behavior
    G = E / (2 * (1 + mu))  # shear modulus
    # 1
    V1 = 0.55 * fy * d_col * tp  # yield force
    M1 = V1 * d_beam  # yield moment
    gamma1 = fy / (G * pow(3, 0.5))  # yield rotation
    K1 = 0.95 * d_col * tp * G  # elastic stiffness
    Kgamma1 = M1 / gamma1  # elastic rotational stiffness
    # 2
    gamma2 = 4.0 * gamma1
    V2 = 0.55 * fy * d_col * tp * (1 + (3.0 * bf * tf ** 2) / (d_beam * d_col * tp))
    M2 = V2 * d_beam
    # 3
    Kgamma3 = 0.03 * Kgamma1
    gamma3 = 100. * gamma1
    M3 = M2 + (gamma3 - gamma2) * Kgamma3
    # Ultimate
    gammaU = 0.3

    # Construct panel zone spring
    if type_ == 1:
        spring_id = 11000000 + Floor * 10000 + Axis * 100
        ops.uniaxialMaterial("Hysteretic", spring_id + 1, M1, gamma1, M2, gamma2, M3, gamma3, -M1, -gamma1, -M2, -gamma2,
                        -M3, -gamma3, 0.25, 0.75, 0., 0., 0.)
        ops.uniaxialMaterial("MinMax", spring_id, spring_id + 1, "-min", -gammaU, "-max", gammaU)
        ops.element("zeroLength", spring_id, node_TR, node_RT, "-mat", spring_id, "-dir", 6)

    if check:
        print(check)
        print(f"M1: {M1}, M2: {M2}, M3: {M3}")
        print(f"gamma1: {gamma1}, gamma2: {gamma2}, gamma3: {gamma3}")
