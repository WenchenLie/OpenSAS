from typing import Literal
import pandas as pd
from scipy.interpolate import RegularGridInterpolator


SSF_TABLE_1 = pd.DataFrame(
    [[1.00, 1.02, 1.04, 1.06, 1.08, 1.09, 1.12, 1.14],
     [1.00, 1.02, 1.05, 1.07, 1.09, 1.11, 1.13, 1.16],
     [1.00, 1.03, 1.06, 1.08, 1.10, 1.12, 1.15, 1.18],
     [1.00, 1.03, 1.06, 1.09, 1.11, 1.14, 1.17, 1.20],
     [1.00, 1.03, 1.07, 1.09, 1.13, 1.15, 1.19, 1.22],
     [1.00, 1.04, 1.08, 1.10, 1.14, 1.17, 1.21, 1.25],
     [1.00, 1.04, 1.08, 1.11, 1.15, 1.18, 1.23, 1.27],
     [1.00, 1.04, 1.09, 1.12, 1.17, 1.20, 1.25, 1.30],
     [1.00, 1.05, 1.10, 1.13, 1.18, 1.22, 1.27, 1.32],
     [1.00, 1.05, 1.10, 1.14, 1.19, 1.23, 1.30, 1.35],
     [1.00, 1.05, 1.11, 1.15, 1.21, 1.25, 1.32, 1.37]],
     columns=[1.0, 1.1, 1.5, 2, 3, 4, 6, 8],  # miuT
     index=[0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5]  # T
)
SSF_TABLE_2 = pd.DataFrame(
    [[1.00, 1.05, 1.10, 1.13, 1.18, 1.22, 1.28, 1.33],
     [1.00, 1.05, 1.11, 1.14, 1.20, 1.24, 1.30, 1.36],
     [1.00, 1.06, 1.11, 1.15, 1.21, 1.25, 1.32, 1.38],
     [1.00, 1.06, 1.12, 1.16, 1.22, 1.27, 1.35, 1.41],
     [1.00, 1.06, 1.13, 1.17, 1.24, 1.29, 1.37, 1.44],
     [1.00, 1.07, 1.13, 1.18, 1.25, 1.31, 1.39, 1.46],
     [1.00, 1.07, 1.14, 1.19, 1.27, 1.32, 1.41, 1.49],
     [1.00, 1.07, 1.15, 1.20, 1.28, 1.34, 1.44, 1.52],
     [1.00, 1.08, 1.16, 1.21, 1.29, 1.36, 1.46, 1.55],
     [1.00, 1.08, 1.16, 1.22, 1.31, 1.38, 1.49, 1.58],
     [1.00, 1.08, 1.17, 1.23, 1.32, 1.40, 1.51, 1.61]],
     columns=[1.0, 1.1, 1.5, 2, 3, 4, 6, 8],  # miuT
     index=[0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5]  # T
)


def get_SFF(T: float, miuT: float, SDC: Literal['B', 'C', 'Dmin', 'Dmax', 'other']) -> float:
    """Get the spectral shape factor (SFF)

    Args:
        T (float): Period
        miuT (float): Period-based ductility
        SDC (Literal['B', 'C', 'Dmin', 'Dmax', 'other']): Seismic design category

    Returns:
        float: spectral shape factor
    """
    if SDC in ['B', 'C', 'Dmin']:
        sff_table = SSF_TABLE_1
    elif SDC == 'Dmax':
        sff_table = SSF_TABLE_2
    elif SDC == 'other':
        return 1
    else:
        raise ValueError(f"Invalid SDC: {SDC}")
    if T < 0.5: T = 0.5
    if T > 1.5: T = 1.5
    if miuT < 1.0: miuT = 1.0
    if miuT > 8.0: miuT = 8.0
    T_values = sff_table.index.values
    muT_values = sff_table.columns.values
    interpolator = RegularGridInterpolator((T_values, muT_values), SSF_TABLE_1.values)
    result: float = interpolator((T, miuT))
    return result
