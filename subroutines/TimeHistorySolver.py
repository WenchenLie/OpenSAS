import numpy as np
import openseespy.opensees as ops
import time
import matplotlib.pyplot as plt
# from subroutines import DisplayModel2D


def TimeHistorySolver(
        dt_init: float, duration: float, story_heights: list,
        ctrl_nodes: list,  CollapseDrift: float, MaxAnalysisDrift: float,
        GMname: str, maxRunTime: float, ShowAnimation: bool,
        min_factor: float=1e-6, max_factor: float=1) -> int:
    """This solver is used to perform time history analysis for frame structure.

    Args:
        dt_init (float): Ground motion step
        duration (float): Ground motion duration
        story_heights (list): Heights of story
        ctrl_nodes (list): Controlled nodes of story
        CollapseDrift (float): Drift ratio that sign the frame as collapse
        MaxAnalysisDrift (float): Drift ratio that analysis termination
        GMname (str): Ground motion name
        maxRunTime (float): Maximum run time (second)
        ShowAnimation (bool): Whether to display the building deformation
        print_result (bool): Whether to print analysis information
        min_factor (float): Factor to control the adaptive time step
        max_factor (float): Factor to control the adaptive time step
    
    Return:
        int: 1 - Analysis finished, the structure did not collapse,
        2 - The structure collapsed,
        3 - Cannot converge,
        4 - Exceeding maximum running time
    """

    algorithms = [("KrylovNewton",), ("NewtonLineSearch",), ("Newton",), ("SecantNewton",)]
    algorithm_id = 0
    ops.wipeAnalysis()
    ops.constraints("Plain")
    ops.numberer("RCM")
    ops.system("UmfPack")
    ops.test("EnergyIncr", 1.0e-3, 100)
    ops.algorithm("KrylovNewton")
    ops.integrator("Newmark", 0.5, 0.25)
    ops.analysis("Transient")

    collapse_flag = False
    print_collapse = True
    factor = 1
    start_time = time.time()
    nstep = 0
    dt = dt_init
    SDRs = np.zeros((10, len(story_heights)))
    SDR_roof = [0] * 10
    collapseTime = 60
    collapseStart = 0
    while True:
        if time.time() - start_time > maxRunTime:
            print("Exceeding maximum running time")
            return 3, ops.getTime(), collapse_flag, SDRs, SDR_roof
        if collapse_flag and time.time() - collapseStart > collapseTime:
            return 2, ops.getTime(), collapse_flag, SDRs, SDR_roof
        ok = ops.analyze(1, dt)
        if ok == 0:
            collapse_flag, maxAna_flag, SDRs_i, SDR_roof_i = SDR_tester(
                story_heights, ctrl_nodes, CollapseDrift, MaxAnalysisDrift, GMname)
            if collapse_flag and collapseStart == 0:
                collapseStart = time.time()
            try:
                SDRs = np.vstack((SDRs, SDRs_i))
            except:
                print(SDRs)
                print(SDRs_i)
                raise ValueError()
            SDR_roof.append(SDR_roof_i)
            if ops.getTime() >= duration:
                print("Analysis finished")
                # if ShowAnimation:
                #     plt.ioff()
                return 1, ops.getTime(), collapse_flag, SDRs, SDR_roof
            if maxAna_flag:
                print("Analysis finished, the structure collapsed")
                # if ShowAnimation:
                #     plt.ioff()
                return 1, ops.getTime(), collapse_flag, SDRs, SDR_roof
            if collapse_flag and print_collapse:
                print("The structure was collapse")
                print_collapse = False
            factor_old = factor
            factor *= 2
            factor = min(factor, max_factor)
            if factor_old < factor:
                print(f"---- Enlarged factor: {factor}, Time: {ops.getTime()}")
            algorithm_id -= 1
            algorithm_id = max(0, algorithm_id)
            # algorithm_id += 1
            # algorithm_id == 4
            # algorithm_id = 0
        else:
            factor *= 0.5
            if factor < min_factor:
                factor = min_factor
                algorithm_id += 1
                if algorithm_id == 4:
                    print("Cannot converge")
                    return 2, ops.getTime(), collapse_flag, SDRs, SDR_roof
                print(f"-------- Switched algorithm:", *algorithms[algorithm_id], f'Time: {ops.getTime()}')
            print(f"---- Reduced factor: {factor}, Time: {ops.getTime()}")
        dt = dt_init * factor
        if dt + ops.getTime() > duration:
            dt = duration - ops.getTime()
        ops.algorithm(*algorithms[algorithm_id])
        nstep += 1
        # if nstep == 20:
        #     break
            

def SDR_tester(story_heights: list, ctrl_nodes: list,
               CollapseDrift: float, MaxAnalysisDrift: float,
               GMname: str) -> tuple[bool, bool, list, float]:
    """
    return (tuple[bool, bool]): Exceeding CollapseDrift? Exceeding MaxAnalysisDrift? 
    """
    if CollapseDrift > MaxAnalysisDrift:
        raise ValueError('`MaxAnalysisDrift` should be larger than `CollapseDrift`')

    SDRs = []
    SDR_roof = ops.nodeDisp(ctrl_nodes[len(story_heights) - 1])[0] / sum(story_heights)
    collapse = (False, False)
    for i, h in enumerate(story_heights):
        if i == 0:
            disp_b = 0
            disp_t = ops.nodeDisp(ctrl_nodes[0])[0]
        else:
            disp_b = ops.nodeDisp(ctrl_nodes[i - 1])[0]
            disp_t = ops.nodeDisp(ctrl_nodes[i])[0]
        SDR = (disp_t - disp_b) / h
        SDRs.append(SDR)
        if SDR >= MaxAnalysisDrift:
            collapse = (True, True)  # TODO
        if SDR >= CollapseDrift:
            collapse = (True, False)  # TODO 这两个if应调换
    return *(collapse), SDRs, SDR_roof




if __name__ == "__main__":
    t = ops.getTime()










