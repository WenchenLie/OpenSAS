import sys
from pathlib import Path
sys.path.append(Path.cwd().as_posix())
from MRFcore.MRF import MRF
from MRFcore.DataProcessing import DataProcessing
from MRFcore.QuakeReadPushover import QuakeReadPushover


if __name__ == "__main__":
    
    output_folder = Path(r'H:\MRF_results\test\MRF4S_CP')

    # 1. Perform pushover analysis
    note = 'pushover analysis of a four-story steel moment resisting frame'
    model = MRF('MRF4S', N=4, notes=note, script='tcl')
    model.set_running_parameters(Output_dir=output_folder, display=True, auto_quit=False)
    cp_path = [0, 0.02, -0.02, 0]
    model.run_cyclic_pushover(RDR_path=cp_path, print_result=True)

    # 2. Read results
    model = DataProcessing(output_folder)
    model.set_output_dir(output_folder.parent / (output_folder.name+'_out'), cover=1)
    model.read_results('mode', 'IDR', 'CIDR', 'PFA', 'PFV', 'shear', 'panelZone', 'beamHinge', 'columnHinge', print_result=True)
    model.read_cyclic_pushover(H=16300)

