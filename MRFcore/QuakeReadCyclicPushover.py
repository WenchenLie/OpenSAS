import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

def QuakeReadCyclicPushover(folder: Path):

    folder = Path(folder)
    weight = 0
    time = np.loadtxt(folder/'Cyclic_pushover'/'Time.out')
    shear = np.zeros(len(time))
    SDR = np.loadtxt(folder/'Cyclic_pushover'/'SDR_Roof.out')
    for i in range(1, 1000):
        if (folder/'Cyclic_pushover'/f'Support{i}.out').exists():
            data = np.loadtxt(folder/'Cyclic_pushover'/f'Support{i}.out')
            weight += data[10, 1]
            shear += data[:, 0]
    shear /= -weight
    print('最大剪力 =', max(shear * abs(weight)))
    print('weight =', weight)
    plt.plot(SDR * 100, shear)
    plt.xlabel('Roof drift ratio [%]')
    plt.ylabel('Normalised base shear, V/W')
    plt.show()


if __name__ == "__main__":
    
    folder = Path(r'H:\MRF_results\test\MRF4S_AS_CP')
    QuakeReadCyclicPushover(folder)


