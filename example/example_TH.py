import sys
from pathlib import Path
sys.path.append(Path.cwd().as_posix())
from MRFcore.MRF import MRF
from MRFcore.DataProcessing import DataProcessing


if __name__ == "__main__":

    output_folder = Path(r'H:\MRF_results\test\MRF4S_PO')
    
    # 1. Perform time history analysis
    note = 'time history of a four-story steel moment resisting frame'
    model = MRF('MRF4S', N=4, notes=note, script='tcl')
    model.select_ground_motions([f'th{i}' for i in range(1, 11)], suffix='.th')
    T1 = 1.242
    model.scale_ground_motions(method='i', para=(T1, 1))
    model.set_running_parameters(Output_dir=output_folder, fv_duration=0, display=True, auto_quit=False)
    model.run_time_history(print_result=False, parallel=10)


    # 2. Read results
    model = DataProcessing(output_folder)
    model.set_output_dir(output_folder.parent / (output_folder.name+'_out'), cover=1)
    model.read_results('mode', 'IDR', 'CIDR', 'PFA', 'PFV', 'shear', 'panelZone', 'beamHinge', 'columnHinge', print_result=True)
    model.read_th()

