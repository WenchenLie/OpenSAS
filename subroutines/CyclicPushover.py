# -------------------------- Cyclic pushover analysis --------------------------
#
# Args (7):
# ---------------
# CtrlNode          Control node at roof
# RDR_path          Loading path of roof drift ratio
# HBuilding         Heights of the building
# Dincr_init        Initial displacement increment
# maxRunTime        Max run time (s)
# ShowAnimation     Show animation
# min_factor        Factor to control the adaptive time step
# max_factor        Factor to control the adaptive time step

# ---------------
# Written by: Wenchen Lie, Guangzhou University, China
# Date: 2024-05-06
# --------------------------------------------------------------------------------


import numpy as np
import openseespy.opensees as ops
import time


def CyclicPushover(
        CtrlNode: int,
        RDR_path: list,
        HBuilding: float,
        Dincr_init: float,
        maxRunTime: float,
        ShowAnimation: bool,
        min_factor: float=1e-6,
        max_factor: float=1):

    ops.wipeAnalysis()
    ops.constraints("Plain")
    ops.numberer("RCM")
    ops.system("UmfPack")
    ops.test("EnergyIncr", 1.e-5, 30)
    ops.algorithm("KrylovNewton")
    ops.integrator("DisplacementControl", CtrlNode, 1 ,Dincr_init)
    ops.analysis("Static")

    for RDR in RDR_path:

        print(f'RDR = {RDR} starts')
        ls_algorithm = ["KrylovNewton", "NewtonLineSearch", "Newton", "SecantNewton"]
        Id_algorithm = 0
        factor = 1.0
        start_time = time.time()
        D_target = RDR * HBuilding
        if D_target >= ops.nodeDisp(CtrlNode, 1):
            direction = 1
        else:
            direction = -1
        Dincr = direction * Dincr_init
        while True:
            if time.time() - start_time >= maxRunTime:
                print("Exceeding maximum running time")
                return 3
            ops.algorithm(ls_algorithm[Id_algorithm])
            ops.integrator("DisplacementControl", CtrlNode, 1, Dincr)
            ok = ops.analyze(1)
            if ok == 0:
                if (direction == 1) and (ops.nodeDisp(CtrlNode, 1) >= D_target):
                    break
                if (direction == -1) and (ops.nodeDisp(CtrlNode, 1) <= D_target):
                    break
                factor_old = factor
                factor = min(factor * 2, max_factor)
                if factor_old < factor:
                    print(f"-- {ops.nodeDisp(CtrlNode, 1)} -- Enlarged factor: {factor}")
                Id_algorithm -= 1
                Id_algorithm = max(0, Id_algorithm)
            else:
                factor = factor * 0.5
                if factor < min_factor:
                    factor = min_factor
                    Id_algorithm += 1
                    if Id_algorithm == 4:
                        print("Cannot converge")
                        return 2
                    print(f"-- {ops.nodeDisp(CtrlNode, 1)} ------ Switched algorithm: {ls_algorithm[Id_algorithm]}")
                print(f"-- {ops.nodeDisp(CtrlNode, 1)} -- Reduced factor: {factor}")
            Dincr = direction * factor * Dincr_init
        # Analysis finished
        print(f"RDR = {RDR} finished")

    return 1

