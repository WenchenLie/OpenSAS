import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

def QuakeReadPushover(folder: Path):

    folder = Path(folder)
    weight = 0
    time = np.loadtxt(folder/'Pushover'/'Time.out')
    shear = np.zeros(len(time))
    SDR = np.loadtxt(folder/'Pushover'/'SDR_Roof.out')
    for i in range(1, 1000):
        if (folder/'Pushover'/f'Support{i}.out').exists():
            data = np.loadtxt(folder/'Pushover'/f'Support{i}.out')
            weight += data[9, 1]
            shear += -data[:, 0]
    shear_norm = shear / weight
    print('最大剪力 =', max(shear))
    print('weight =', weight)
    plt.subplot(121)
    plt.plot(SDR * 100, shear_norm)
    plt.xlabel('Roof drift ratio [%]')
    plt.ylabel('Normalised base shear, V/W')
    plt.xlim(0, 10)
    # plt.ylim(0)
    plt.subplot(122)
    plt.plot(SDR * 100, shear / 1000)
    plt.xlabel('Roof drift ratio [%]')
    plt.ylabel('Base shear [kN]')
    plt.xlim(0, 10)
    # plt.ylim(0)
    plt.tight_layout()
    plt.show()


if __name__ == "__main__":
    
    folder = Path(r'E:\MRF_results\test\4SMRF')
    QuakeReadPushover(folder)


