import pandas as pd
import numpy as np
from scipy.interpolate import interp1d


ACCEPTABLE_ACMR = pd.DataFrame(
    [[0.275, 1.57, 1.42, 1.33, 1.26, 1.20],
     [0.300, 1.64, 1.47, 1.36, 1.29, 1.22],
     [0.325, 1.71, 1.52, 1.40, 1.31, 1.25],
     [0.350, 1.78, 1.57, 1.44, 1.34, 1.27],
     [0.375, 1.85, 1.62, 1.48, 1.37, 1.29],
     [0.400, 1.93, 1.67, 1.51, 1.40, 1.31],
     [0.425, 2.01, 1.72, 1.55, 1.43, 1.33],
     [0.450, 2.10, 1.78, 1.59, 1.46, 1.35],
     [0.475, 2.18, 1.84, 1.64, 1.49, 1.38],
     [0.500, 2.28, 1.90, 1.68, 1.52, 1.40],
     [0.525, 2.37, 1.96, 1.72, 1.56, 1.42],
     [0.550, 2.47, 2.02, 1.77, 1.59, 1.45],
     [0.575, 2.57, 2.09, 1.81, 1.62, 1.47],
     [0.600, 2.68, 2.16, 1.86, 1.66, 1.50],
     [0.625, 2.80, 2.23, 1.91, 1.69, 1.52],
     [0.650, 2.91, 2.30, 1.96, 1.73, 1.55],
     [0.675, 3.04, 2.38, 2.01, 1.76, 1.58],
     [0.700, 3.16, 2.45, 2.07, 1.80, 1.60],
     [0.725, 3.30, 2.53, 2.12, 1.84, 1.63],
     [0.750, 3.43, 2.61, 2.18, 1.88, 1.66],
     [0.775, 3.58, 2.70, 2.23, 1.92, 1.69],
     [0.800, 3.73, 2.79, 2.29, 1.96, 1.72],
     [0.825, 3.88, 2.88, 2.35, 2.00, 1.74],
     [0.850, 4.05, 2.97, 2.41, 2.04, 1.77],
     [0.875, 4.22, 3.07, 2.48, 2.09, 1.80],
     [0.900, 4.39, 3.17, 2.54, 2.13, 1.83],
     [0.925, 4.58, 3.27, 2.61, 2.18, 1.87],
     [0.950, 4.77, 3.38, 2.68, 2.22, 1.90]
    ], columns=['beta_TOT', 'ACMR5', 'ACMR10', 'ACMR15', 'ACMR20', 'ACMR25']
)  # FEMA P695, Table 7-3

def get_acceptable_ACMR(beta_TOT: float) -> tuple[float, float, float, float, float]:
    beta_TOT = max(beta_TOT, 0.275)
    beta_TOT = min(beta_TOT, 0.950)
    all_beta_TOT = ACCEPTABLE_ACMR['beta_TOT'].values
    get_ACMR5 = interp1d(all_beta_TOT, ACCEPTABLE_ACMR['ACMR5'].values, kind='linear')
    get_ACMR10 = interp1d(all_beta_TOT, ACCEPTABLE_ACMR['ACMR10'].values, kind='linear')
    get_ACMR15 = interp1d(all_beta_TOT, ACCEPTABLE_ACMR['ACMR15'].values, kind='linear')
    get_ACMR20 = interp1d(all_beta_TOT, ACCEPTABLE_ACMR['ACMR20'].values, kind='linear')
    get_ACMR25 = interp1d(all_beta_TOT, ACCEPTABLE_ACMR['ACMR25'].values, kind='linear')
    ACMR5 = float(get_ACMR5(beta_TOT))
    ACMR10 = float(get_ACMR10(beta_TOT))
    ACMR15 = float(get_ACMR15(beta_TOT))
    ACMR20 = float(get_ACMR20(beta_TOT))
    ACMR25 = float(get_ACMR25(beta_TOT))
    return ACMR5, ACMR10, ACMR15, ACMR20, ACMR25

if __name__ == "__main__":
    print(get_acceptable_ACMR(0.99))
