import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path


folder = Path(r'H:/MRF_results/test/4SMRF_AE')

weight = 0
time = np.loadtxt(folder/'Pushover'/'Time.out')
shear = np.zeros(len(time))
SDR = np.loadtxt(folder/'Pushover'/'SDRALL_MF.out')
for i in range(1, 1000):
    if (folder/'Pushover'/f'Support{i}.out').exists():
        data = np.loadtxt(folder/'Pushover'/f'Support{i}.out')
        weight += data[10, 1]
        shear += data[:, 0]
shear /= -weight
print('最大剪力 =', max(shear * abs(weight)))
print('weight =', weight)
plt.plot(SDR * 100, shear)
plt.xlabel('Roof drift ratio [%]')
plt.ylabel('Normalised base shear, V/W')
plt.xlim(0, 6)
plt.ylim(0)
plt.show()
plt.show()




