import openseespy.opensees as ops
import time


def PushoverAnalysis(
        CtrlNode: int, Dmax: float, Dincr_init: float,
        maxRunTime: float,
        min_factor: float=1e-6, max_factor: float=1):

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

    Dincr = Dincr_init
    while True:
        if time.time() - start_time >= maxRunTime:
            print("Exceeding maximum running time")
            return 3, ops.nodeDisp(CtrlNode, 1)
        ops.algorithm(ls_algorithm[Id_algorithm])
        ops.integrator("DisplacementControl", CtrlNode, 1, Dincr)
        ok = ops.analyze(1)
        if ok == 0:
            if ops.nodeDisp(CtrlNode, 1) >= Dmax:
                print("Analysis finished")
                return 1, ops.nodeDisp(CtrlNode, 1)
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
                    return 2, ops.nodeDisp(CtrlNode, 1)
                print(f"-- {ops.nodeDisp(CtrlNode, 1)} ------ Switched algorithm: {ls_algorithm[Id_algorithm]}")
            print(f"-- {ops.nodeDisp(CtrlNode, 1)} -- Reduced factor: {factor}")
        Dincr = factor * Dincr_init







