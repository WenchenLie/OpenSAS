# -------------------------- Construct beam hinge model --------------------------
#
# Args (17):
# ---------------
# SpringID       Zero length element ID
# NodeI          Node i ID
# NodeJ          Node j ID
# E              Young's modulus
# fy             Yield strength
# Ix             Moment of inertia of section
# d              Section depth
# htw            Web slenderness ratio
# bftf           Flange slenderness ratio
# ry             Radius of gyration
# L              Member Length
# Ls             Shear Span
# Lb             Unbraced length
# My             Effective Yield Moment
# type_          Type of beam-to-column connection
#                   1: Reduced beam section (RBS)
#                   2: Other than RBS
#                   3: Pinned
#                   4: Elastic
# check          If given, print IMK model parameters
# 
# ---------------
# Reference:
# [1] Deterioration Modeling of Steel Components in Support of Collapse Prediction of Steel Moment Frames under Earthquake Loading
# ---------------
# Written by: Wenchen Lie, Guangzhou University, China
# Date: 2024-03-26
# --------------------------------------------------------------------------------
import openseespy.opensees as ops
from typing import Literal


def BeamHinge(
    SpringID: int, NodeI: int, NodeJ: int,
    E: float, fy: float,
    Ix: float, d: float, htw: float, bftf: float,
    ry: float, L: float, Ls: float, Lb: float,
    My: float, type_: Literal[1, 2, 3], check: bool=None):
    
    n = 10.0
    c1 = 1.0
    c2 = 1.0

    K = (n + 1.0) * 6 * E * Ix / L

    McMy = 1.1
    if type_ == 1:
        # RBS hinge
        theta_p = 0.19 * ((htw) ** -0.314) * ((bftf) ** -0.100) * ((Lb / ry) ** -0.185) * ((Ls / d) ** 0.113) * (
                    (c1 * d / 533) ** -0.760) * ((c2 * fy / 355) ** -0.070)
        theta_pc = 9.52 * ((htw) ** -0.513) * ((bftf) ** -0.863) * ((Lb / ry) ** -0.108) * ((c2 * fy / 355) ** -0.360)
        Lamda = 585 * ((htw) ** -1.140) * ((bftf) ** -0.632) * ((Lb / ry) ** -0.205) * ((c2 * fy / 355) ** -0.391)
    elif type_ == 2:
        # Other than RBS section
        if d >= 533.0:
            theta_p = 0.318 * ((htw) ** -0.550) * ((bftf) ** -0.345) * ((Lb / ry) ** -0.023) * ((Ls / d) ** 0.090) * (
                        (c1 * d / 533) ** -0.330) * ((c2 * fy / 355) ** -0.130)
            theta_pc = 7.500 * ((htw) ** -0.610) * ((bftf) ** -0.710) * ((Lb / ry) ** -0.110) * ((c1 * d / 533) ** -0.161) * (
                        (c2 * fy / 355) ** -0.320)
            Lamda = 536 * ((htw) ** -1.260) * ((bftf) ** -0.525) * ((Lb / ry) ** -0.130) * ((c2 * fy / 355) ** -0.291)
        else:
            theta_p = 0.0865 * ((htw) ** -0.360) * ((bftf) ** -0.140) * ((Ls / d) ** 0.340) * ((c1 * d / 533) ** -0.721) * (
                        (c2 * fy / 355) ** -0.230)
            theta_pc = 5.6300 * ((htw) ** -0.565) * ((bftf) ** -0.800) * ((c1 * d / 533) ** -0.280) * (
                        (c2 * fy / 355) ** -0.430)
            Lamda = 495 * ((htw) ** -1.340) * ((bftf) ** -0.595) * ((c2 * fy / 355) ** -0.360)

    if type_ == 3:
        # Beam column hinged connection
        ops.element("zeroLength", SpringID, NodeI, NodeJ, "-mat", 99, 99, 9, "-dir", 1, 2, 6)
        # ops.element("zeroLength", SpringID, NodeI, NodeJ, "-mat", 9, "-dir", 6)
        # ops.equalDOF(NodeI, NodeJ, 1, 2)
    elif type_ == 4:
        # Elastic
        ops.uniaxialMaterial("Elastic", SpringID, K)
        ops.element("zeroLength", SpringID, NodeI, NodeJ, "-mat", 99, 99, SpringID, "-dir", 1, 2, 6)
    else:
        theta_u = 0.2
        D = 1.0
        Res = 0.4
        c = 1.0
        ops.uniaxialMaterial("IMKBilin", SpringID, K, theta_p, theta_pc, theta_u, My, McMy, Res, theta_p, theta_pc, theta_u, My, McMy, Res, Lamda, Lamda, Lamda, c, c, c, D, D)
        ops.element("zeroLength", SpringID, NodeI, NodeJ, "-mat", 99, 99, SpringID, "-dir", 1, 2, 6)
        # ops.element("zeroLength", SpringID, NodeI, NodeJ, "-mat", SpringID, "-dir", 6)
        # ops.equalDOF(NodeI, NodeJ, 1, 2)

        if check:
            print(f"{check}:\nKs: {K}, My: {My}, theta_p: {theta_p}, theta_pc: {theta_pc}, Res: {Res}")

