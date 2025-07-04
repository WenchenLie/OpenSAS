from pathlib import Path
from MRFcore.model import Model
from MRFcore.data_processing import DataProcessing
from MRFcore.quake_read_pushover import QuakeReadPushover


if __name__ == "__main__":
    
    output_folder = Path(r'H:\MRF_results\test\MRF4S_CP')

    # 1. Perform pushover analysis
    note = 'pushover analysis of a four-story steel moment resisting frame'
    model = Model('MRF4S', Nstory=4, Nbay=3, notes=note, script='tcl')
    model.set_running_parameters(Output_dir=output_folder, display=True, auto_quit=False)
    cp_path = [0, 0.02, -0.02, 0.04, -0.04, 0]
    model.run_cyclic_pushover(RDR_path=cp_path, print_result=True)

    # 2. Read results
    model = DataProcessing(output_folder)
    model.set_output_dir(output_folder.parent / (output_folder.name+'_out'), cover=1)
    model.read_results('mode', 'IDR', 'CIDR', 'PFA', 'PFV', 'shear', 'panelZone', 'beamHinge', 'columnHinge', print_result=True)
    model.read_cyclic_pushover(H=16300)

