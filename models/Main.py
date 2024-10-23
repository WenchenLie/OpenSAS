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
TSBF4S          0.56  0.175 0.099

"""

def run():

    note2 = ''
    model = MRF('MRF4S', N=4, notes=note2, script='tcl')
    # model.select_ground_motions([f'th{i}' for i in range(1, 45)], suffix='.th')
    # model.select_ground_motions([f'GM{i}' for i in range(1, 12)], suffix='.txt')
    # model.select_ground_motions(['th1'], suffix='.th')
    T1 = 1.242
    # model.scale_ground_motions(method='f', para=3, plot=True, SF_code=1)  # 只有跑时程需要定义
    model.set_running_parameters(Output_dir=r'H:\MRF_results\test', fv_duration=0, display=True, auto_quit=False)
    model.OS_path = 'opensees'
    # model.run_time_history(print_result=True, parallel=0)
    # model.run_IDA(T1, 0.2, 0.2, 0.02, max_ana=80, parallel=0, print_result=False)
    model.run_pushover(0.1, print_result=True)
    # cp_path = np.loadtxt('data/cyclic_pushover_path.txt').tolist()
    # cp_path = [0, 0.02, -0.02, 0]
    # model.run_cyclic_pushover(cp_path, print_result=True)


def data_processing():

    time0 = time.time()
    model = DataProcessing(r'H:\RockingFrameWithRSRD\MRF4S_AS_RD1_MCE', gm_suffix='.txt', gm_file=r'F:\Papers\RSRD3\RockingMRF\GMs')
    model.set_output_dir(r'H:\RockingFrameWithRSRD\test\MRF4S_AS_RD1_MCE_out', cover=1)
    model.read_results('mode', 'IDR')
    model.read_results('CIDR', 'PFA', 'PFV', 'shear', 'panelZone', 'beamHinge', 'columnHinge', print_result=True)
    # model.read_results('CIDR', 'PFA', 'PFV', 'shear', print_result=True)
    # model.read_pushover(H=24300, plot_result=True)
    model.read_th()  # 只有时程分析工况需要用
    # model.read_cyclic_pushover(H=16300)
    time1 = time.time()
    print('耗时', time1 - time0)


def fragility_analysis():

    # 层间位移角
    model = FragilityAnalysis(
        r'H:/RCF_results/6SRCF1_TMIW_out',
        DM_types=['IDR', 'PFA'],
        collapse_limit=0.1,
    )
    model.calc_IDA()
    model.frag_curve(
        damage_states={'IDR': [0.005, 0.01, 0.02, 0.04],
                       'PFA': [0.1, 0.2]},
        labels={'IDR': ['DS-1', 'DS-2', 'DS-3', 'DS-4'],
               'PFA': ['DS-1', 'DS-2']}
    )
    model.exceedance_probability(
        DM_values={'IDR': 0.1, 'PFA': 0.2},
    )
    model.collapse_evaluation(T1=1.2, MCE_spec=r'F:\Projects\MRF\data\DBE_AS.txt', SF_spec=1.5)
    model.visualization()
    model.save_data(r'H:/RCF_results/6SRCF1_TMIW_out_frag')



if __name__ == "__main__":

    # MRF.dir_model = Path(r'F:\Projects\ModelRepository\models_TSBF')
    # run()
    # QuakeReadPushover(r'H:\MRF_results\test')
    QuakePlotHinge(r'H:\MRF_results\test\Pushover', 'c', floor=1, axis=1, position='T')
    # data_processing()
    # fragility_analysis()

    pass


