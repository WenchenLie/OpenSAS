# OpenSAS model bridge (Version 2.6.3)
import sys
from pathlib import Path
PROJECT = Path('F:\\\u98ce\u673aTMD\u57fa\u4e8e\u98ce\u9669\u4f18\u5316\\turbine-modeling')
if str(PROJECT) not in sys.path:
    sys.path.insert(0, str(PROJECT))
from NREL5MW import run_openseespy
