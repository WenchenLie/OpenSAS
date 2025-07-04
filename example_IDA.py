from pathlib import Path
import numpy as np
from MRFcore.model import Model
from MRFcore.data_processing import DataProcessing
from MRFcore.fragility_analysis import FragilityAnalysis


if __name__ == "__main__":

    output_folder = Path(r'H:\MRF_results\test\MRF4S_IDA')
        
    # 1. Perform IDA
    note = 'IDA of a four-story steel moment resisting frame'
    model = Model('MRF4S', Nstory=4, Nbay=3, notes=note, script='tcl')
    model.select_ground_motions([f'th{i}' for i in range(1, 45)], suffix='.th')
    T1 = 1.242
    model.set_running_parameters(Output_dir=output_folder, fv_duration=0, display=True, auto_quit=False)
    model.run_IDA(T1, 0.2, 0.2, 0.02, max_ana=80, parallel=22, print_result=False)


    # 2. Read results
    model = DataProcessing(output_folder)
    model.set_output_dir(output_folder.parent / (output_folder.name+'_out'), cover=1)
    model.read_results('mode', 'IDR', 'CIDR', 'PFA', 'PFV', 'shear', 'panelZone', 'beamHinge', 'columnHinge', print_result=True)


    # 3. Fragility analysis
    model = FragilityAnalysis(
        root=output_folder.parent / (output_folder.name+'_out'),
        EDP_types=['IDR', 'RIDR', 'PFA'],
        collapse_limit=0.1,
    )
    model.calc_IDA('IDR')
    model.calc_IDA('RIDR')
    model.calc_IDA('PFA')
    model.frag_curve('IDR', {'DS-1': 0.005, 'DS-2': 0.02, 'DS-3': 0.04}, beta=0.4)
    model.frag_curve('RIDR', {'DS-1': 0.002, 'DS-2': 0.005, 'DS-3': 0.01}, beta=0.4)
    model.frag_curve('PFA', {'DS-1': 1, 'DS-2': 1.5, 'DS-3': 2}, beta=0.4, IM_limit=8)
    hazard_curves = np.loadtxt(f'data/hazard_curve_1.242.out')
    model.manual_probability('IDR', (0.001, 5), (0.001, 0.05), hazard_curves, 'PSDM')
    model.manual_probability('RIDR', (0.001, 5), (0.001, 0.02), hazard_curves, 'PSDM')
    model.manual_probability('PFA', (0.001, 5), (0.001, 3), hazard_curves, 'PSDM')
    model.collapse_evaluation(T=T1, MCE_spec='data/DBE_AS.txt', SF_spec=1.5, miuT=10, beta=[0.4, 0.5, 0.6], SDC='Dmax')
    model.visualization()
    model.save_data(output_folder.parent / (output_folder.name+'_frag'))


