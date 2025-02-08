import numpy as np
import time
from pathlib import Path
from MRFcore.MRF import MRF
from MRFcore.QuakeReadPushover import QuakeReadPushover
from MRFcore.QuakeReadCyclicPushover import QuakeReadCyclicPushover
from MRFcore.QuakePlotHinge import QuakePlotHinge
from MRFcore.DataProcessing import DataProcessing
from MRFcore.FragilityAnalysis import FragilityAnalysis

"""
周期备忘：
MRF4S:
MRF6S: 1.581 0.537 0.288
MRF8S: 1.987 0.701 0.382 0.248 0.174 0.13  0.102 0.081
"""

def run():

    note2 = ''
    model = MRF('MRF6S', Nstory=6, Nbay=3, notes=note2, script='tcl')
    model.select_ground_motions([f'th{i}' for i in range(1, 45)], suffix='.th')
    # model.select_ground_motions([f'GM{i}' for i in range(1, 12)], suffix='.txt')
    # model.select_ground_motions(['th1'], suffix='.th')
    T1 = 1.581
    # model.scale_ground_motions(method='f', para=3, plot=True, SF_code=1)  # 只有跑时程需要定义
    model.set_running_parameters(Output_dir=r'H:\MRF_results\MRF6S', fv_duration=30, display=True, auto_quit=True)
    # model.set_running_parameters(Output_dir=r'H:\MRF_results\test', fv_duration=30, display=True, auto_quit=True)
    model.OS_path = 'opensees'
    # model.run_time_history(print_result=True, parallel=0)
    model.run_IDA(T1, 0.1, 0.1, 0.01, max_ana=80, parallel=22, print_result=False)
    # model.run_pushover(0.1, print_result=True)
    # cp_path = np.loadtxt('data/cyclic_pushover_path.txt').tolist()
    # cp_path = [0, 0.02, -0.02, 0]
    # model.run_cyclic_pushover(cp_path, print_result=True)


def data_processing():

    time0 = time.time()
    model = DataProcessing(r'H:\MRF_results\MRF6S')
    model.set_output_dir(r'H:\MRF_results\MRF6S_out', cover=1)
    model.read_results('mode', 'IDR')
    model.read_results('CIDR', 'PFA', 'PFV', 'shear', 'panelZone', 'beamHinge', 'columnHinge', print_result=True)
    # model.read_results('CIDR', 'PFA', 'PFV', 'shear', print_result=True)
    # model.read_pushover(H=24300, plot_result=True)
    # model.read_th()  # 只有时程分析工况需要用
    # model.read_cyclic_pushover(H=16300)
    time1 = time.time()
    print('耗时', time1 - time0)


def fragility_analysis():
    model = FragilityAnalysis(
        root=r'H:\MRF_results\4SMRF_AS_out',
        EDP_types=['IDR', 'RIDR', 'PFA'],
        collapse_limit=0.1,
    )
    model.calc_IDA('IDR')
    model.calc_IDA('RIDR')
    model.calc_IDA('PFA')
    model.frag_curve('IDR', {'DS-1': 0.005, 'DS-2': 0.01, 'DS-3': 0.02, 'DS-4': 0.04}, beta=0.4)
    model.frag_curve('RIDR', {'DS-1': 0.001, 'DS-2': 0.002, 'DS-3': 0.005, 'DS-4': 0.01}, beta=0.4)
    model.frag_curve('PFA', {'DS-1': 0.2, 'DS-2': 0.5, 'DS-3': 1}, beta=0.4)
    model.exceedance_probability('IDR', 0.1)
    hazard_curves = np.loadtxt('data/hazard_curve_1.242.out')
    model.collapse_evaluation(T=1.987, MCE_spec='data1/DBE_AS.txt', SF_spec=1.5)
    model.visualization()
    model.manual_probability('IDR', (0.001, 5), (0.001, 0.1), hazard_curves)
    model.save_data(r'H:\MRF_results\4SMRF_AS_frag')


if __name__ == "__main__":

    # MRF.dir_model = Path(r'F:\Projects\ModelRepository\models_TSBF')
    # run()
    # QuakeReadPushover(r'H:\MRF_results\test')
    # QuakePlotHinge(r'H:\MRF_results\test\Pushover', 'c', floor=1, axis=1, position='T')
    # data_processing()
    fragility_analysis()

    pass


