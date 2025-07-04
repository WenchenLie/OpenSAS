import sys
from pathlib import Path
sys.path.append(Path.cwd().as_posix())
from MRFcore.model import Model
from MRFcore.data_processing import DataProcessing


if __name__ == "__main__":
    
    output_folder = Path(r'H:\MRF_results\test\MRF4S_PO')

    # 1. Perform pushover analysis
    note = 'pushover analysis of a four-story steel moment resisting frame'
    model = Model('MRF4S', Nstory=4, Nbay=3, notes=note, script='tcl')
    model.set_running_parameters(Output_dir=output_folder, display=True, auto_quit=False)
    model.run_pushover(print_result=True)

    # 2. Read results
    model = DataProcessing(output_folder)
    model.set_output_dir(output_folder.parent / (output_folder.name+'_out'), cover=1)
    model.read_results('mode', 'IDR', 'CIDR', 'PFA', 'PFV', 'shear', 'panelZone', 'beamHinge', 'columnHinge', print_result=True)
    model.read_pushover(H=16300)

