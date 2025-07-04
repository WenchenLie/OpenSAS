import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
from typing import Literal


def QuakePlotHinge(folder: Path, hinge: Literal['b', 'c', 'pz'], floor: int=None, axis: int=None, position: Literal['B', 'T', 'L', 'R']=None):
    folder = Path(folder)
    if not folder.exists():
        raise ValueError(f'`{folder}`不存在')
    if hinge == 'b':
        if not all([floor, axis, position]):
            raise ValueError('梁铰位置参数有误')
        theta = np.loadtxt(folder/f'BeamSpring{floor}_{axis}{position}.out')[:, 1]
        M = np.loadtxt(folder/f'BeamSpring{floor}_{axis}{position}.out')[:, 0]
    if hinge == 'c':
        if not all([floor, axis, position]):
            raise ValueError('柱铰位置参数有误')
        theta = np.loadtxt(folder/f'ColSpring{floor}_{axis}{position}.out')[:, 1]
        M = np.loadtxt(folder/f'ColSpring{floor}_{axis}{position}.out')[:, 0]
    if hinge == 'pz':
        if not all([floor, axis]):
            raise ValueError('节点域铰位置参数有误')
        theta = np.loadtxt(folder/f'PZ{floor}_{axis}.out')[:, 1]
        M = np.loadtxt(folder/f'PZ{floor}_{axis}.out')[:, 0]
    plt.plot(theta, M/1e6)
    plt.xlabel('theta [rad]')
    plt.ylabel('M [kN-m]')
    plt.show()
    return theta, M / 1e6


if __name__ == "__main__":

    folder = Path(r'H:/MRF_results/test/4SMRF/Pushover')
    theta, M = QuakePlotHinge(folder, hinge='b', floor=4, axis=1, position='R')
    plt.plot(theta, -M)
    plt.xlabel('theta [rad]')
    plt.ylabel('M [kN-m]')
    plt.show()





