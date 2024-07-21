import sys
from pathlib import Path
sys.path.append(Path.cwd().as_posix())
from MRFcore.MRF import MRF
from MRFcore.DataProcessing import DataProcessing
from MRFcore.FragilityAnalysis import FragilityAnalysis


if __name__ == "__main__":

    output_folder = Path(r'H:\MRF_results\test\MRF4S_PO')
        
    # 1. Perform IDA
    note = 'IDA of a four-story steel moment resisting frame'
    model = MRF('MRF4S', N=4, notes=note, script='tcl')
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
        output_folder.parent / (output_folder.name+'_out'),
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
    model.collapse_evaluation(T1=1.2, MCE_spec=r'data\DBE_AS.txt', SF_spec=1.5)
    model.visualization()
    model.save_data(output_folder.parent / (output_folder.name+'_frag'))


