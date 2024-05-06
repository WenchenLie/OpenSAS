# -------------------------- Construct beam hinge model --------------------------
#
# Args (14):
# ---------------
# SpringID       Zero length element ID
# NodeI          Node i ID
# NodeJ          Node j ID
# E              Young's modulus
# Ix             Moment of inertia of section
# d              Section depth
# htw            Web slenderness ratio
# ry             Radius of gyration
# L              Member Length
# Lb             Unbraced length
# My             Effective Yield Moment
# PPy            Axial load ratio due to gravity
# SF_PPy         Scale factor of axial load ratio (due to overturning effect)
# type_          Column base pinned connection (1: fixed, 2: pinned, 3: elastic)
# check          Print IMK model parameters
# 
# ---------------
# Reference:
# [1] Proposed Updates to the ASCE 41 Nonlinear Modeling Parameters for Wide-Flange Steel Columns in Support of Performance-Based Seismic Engineering
# ---------------
# Written by: Wenchen Lie, Guangzhou University, China
# Date: 2024-03-26
# --------------------------------------------------------------------------------

import openseespy.opensees as ops
from typing import Literal


def ColumnHinge(
    SpringID: int, NodeI: int, NodeJ: int,
    E: float, Ix: float, d: float, htw: float, ry: float,
    L: float, Lb: float, My: float, PPy: float,
    SF_PPy: float, type_: Literal[1, 2, 3], check: bool=None):
    
    n = 10.0
    c1 = 1.0
    c2 = 1.0
    PPy *= float(SF_PPy)  # Enlarge PPy for considering overturning effect

    K = (n + 1.0) * 6 * E * Ix / L

    theta_p = 294.0 * ((htw) ** -1.700) * ((Lb / ry) ** -0.700) * ((1 - PPy) ** 1.600)  # Eq. (7)
    theta_pc = 90.0 * ((htw) ** -0.800) * ((Lb / ry) ** -0.800) * ((1 - PPy) ** 2.500)  # Eq. (9)
    if theta_p > 0.20:
        theta_p = 0.2
    if theta_pc > 0.30:
        theta_pc = 0.3

    if PPy <= 0.35:
        Lamda = 25500.0 * ((htw) ** -2.140) * ((Lb / ry) ** -0.530) * ((1 - PPy) ** 4.920)
    else:
        Lamda = 268000.0 * ((htw) ** -2.300) * ((Lb / ry) ** -1.300) * ((1 - PPy) ** 1.190)
    if Lamda < 3.0:
        Lamda = 3.0

    if PPy < 0.2:
        My = (1.15 / 1.1) * My * (1 - PPy / 2)
    else:
        My = (1.15 / 1.1) * My * (9 / 8) * (1 - PPy)
    # Eq. (2)

    McMy = 12.5 * ((htw) ** -0.200) * ((Lb / ry) ** -0.400) * ((1 - PPy) ** 0.400)  # Eq. (3)
    if McMy < 1.0:
        McMy = 1.0
    if McMy > 1.3:
        McMy = 1.3

    theta_u = 0.15
    D = 1.0
    Res = 0.5 - 0.4 * PPy  # Eq. (5)
    c = 1.0

    if type_ == 1:
        ops.uniaxialMaterial("IMKBilin", SpringID, K, theta_p, theta_pc, theta_u, My, McMy, Res, theta_p, theta_pc, theta_u, My, McMy, Res, Lamda, 0.9 * Lamda, 0.9 * Lamda, c, c, c, D, D)
        ops.element("zeroLength", SpringID, NodeI, NodeJ, "-mat", 99, 99, SpringID, "-dir", 1, 2, 6)
        # ops.element("zeroLength", SpringID, NodeI, NodeJ, "-mat", SpringID, "-dir", 6)
        # ops.equalDOF(NodeI, NodeJ, 1, 2)
    elif type_ == 2:
        ops.uniaxialMaterial("IMKBilin", SpringID, K, theta_p, theta_pc, theta_u, My, McMy, Res, theta_p, theta_pc, theta_u, My, McMy, Res, Lamda, 0.9 * Lamda, 0.9 * Lamda, c, c, c, D, D)
        ops.element("zeroLength", SpringID, NodeI, NodeJ, "-mat", 99, 99, 9, "-dir", 1, 2, 6)
        # ops.element("zeroLength", SpringID, NodeI, NodeJ, "-mat", 9, "-dir", 6)
        # ops.equalDOF(NodeI, NodeJ, 1, 2)
    elif type_ == 3:
        # Elastic
        ops.uniaxialMaterial("Elastic", SpringID, K)
        ops.element("zeroLength", SpringID, NodeI, NodeJ, "-mat", 99, 99, SpringID, "-dir", 1, 2, 6)
    if check:
        print(f"{check}:\nKs: {K}, My: {My}, theta_p: {theta_p}, theta_pc: {theta_pc}, Res: {Res}")


