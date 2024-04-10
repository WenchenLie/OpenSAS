import numpy as np
import openseespy.opensees as ops
import time


def PushoverAnalysis(
        CtrlNodes: list, story_heights: list,
        Dmax: float, Dincr_init: float, maxRunTime: float,
        ShowAnimation: bool,
        min_factor: float=1e-6, max_factor: float=1):

    CtrlNode = CtrlNodes[-1]
    ops.wipeAnalysis()
    ops.constraints("Plain")
    ops.numberer("RCM")
    ops.system("UmfPack")
    ops.test("EnergyIncr", 1.e-5, 30)
    ops.algorithm("KrylovNewton")
    ops.integrator("DisplacementControl", CtrlNode, 1 ,Dincr_init)
    ops.analysis("Static")

    ls_algorithm = ["KrylovNewton", "NewtonLineSearch", "Newton", "SecantNewton"]
    Id_algorithm = 0
    factor = 1.0
    start_time = time.time()


    SDRs = np.zeros((10, len(story_heights)))
    SDR_roof = [0] * 10
    Dincr = Dincr_init
    while True:
        if time.time() - start_time >= maxRunTime:
            print("Exceeding maximum running time")
            return 3, ops.nodeDisp(CtrlNode, 1), SDRs, SDR_roof
        ops.algorithm(ls_algorithm[Id_algorithm])
        ops.integrator("DisplacementControl", CtrlNode, 1, Dincr)
        ok = ops.analyze(1)
        if ok == 0:
            SDRs_i, SDR_roof_i = get_SDR(CtrlNodes, story_heights)
            SDRs = np.vstack((SDRs, SDRs_i))
            SDR_roof.append(SDR_roof_i)
            if ops.nodeDisp(CtrlNode, 1) >= Dmax:
                print("Analysis finished")
                return 1, ops.nodeDisp(CtrlNode, 1), SDRs, SDR_roof
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
                    return 2, ops.nodeDisp(CtrlNode, 1), SDRs, SDR_roof
                print(f"-- {ops.nodeDisp(CtrlNode, 1)} ------ Switched algorithm: {ls_algorithm[Id_algorithm]}")
            print(f"-- {ops.nodeDisp(CtrlNode, 1)} -- Reduced factor: {factor}")
        Dincr = factor * Dincr_init


def get_SDR(ctrlNodes, story_heights):
    SDRs = []
    for i, h in enumerate(story_heights):
        if i == 0:
            disp_b = 0
            disp_t = ops.nodeDisp(ctrlNodes[0])[0]
        else:
            disp_b = ops.nodeDisp(ctrlNodes[i - 1])[0]
            disp_t = ops.nodeDisp(ctrlNodes[i])[0]
        if i == len(story_heights) - 1:
            SDR_roof = disp_t / sum(story_heights)
        SDR = (disp_t - disp_b) / h
        SDRs.append(SDR)
    return SDRs, SDR_roof








