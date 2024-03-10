import numpy as np
import requests
import re
from pathlib import Path
from wsection import WSection


def get_rocking_property(section):
    """根据摇摆跨构件所在的层、跨等信息，获得构件属性(A、I、W)

    Args:
        section (str): 截面型号(W14x90, HSS6x4x5/16, ...)

    Return:
        float: 截面高度(H)\n
        float: 截面积(A)\n
        float: 弱轴惯性矩(Iy)\n
        float: 强轴惯性矩(Iz)\n
        float: 抗弯截面系数(W)\n
    """
    path = Path(__file__).parent
    section1 = section.replace('/', '_')
    if Path(f'{path}/{section1}.txt').exists():
        data = np.loadtxt(f'{path}/{section1}.txt')
        H, A, Iy, Iz, W = data
        H, A, Iy, Iz, W = map(int, [H, A, Iy, Iz, W])
    else:
        if section[0] == 'W':
            url = res = f'http://beamdimensions.com/database/American/AISC/W_shapes/{section}/'
            res = requests.get(url)
        elif section[:3] == 'HSS':
            url = f'http://beamdimensions.com/database/American/AISC/Rectangular_HSS/{section}/'
            res = requests.get(url)
        if res.status_code == 404:
            raise ValueError(f'【Error】请求失败: {url}')
        text = res.text
        pattern1 = re.compile(r'The depth of the section is ([0-9.]+) in.')
        pattern2 = re.compile(r'<tr>[ ]+<td>([0-9.]+) in<sup>2</sup></td>[ ]+<td>[0-9.]+ in<sup>4</sup></td>[ ]+<td>([0-9.]+) in<sup>4</sup></td>[ ]+<td>([0-9.]+) in<sup>4</sup></td>')
        H = float(re.search(pattern1, text).group(1)) * 25.4
        A = float(re.search(pattern2, text).group(1)) * 25.4**2
        Iy = float(re.search(pattern2, text).group(2)) * 25.4**4
        Iz = float(re.search(pattern2, text).group(3)) * 25.4**4
        W = Iz / (H / 2)
        H, A, Iy, Iz, W = map(int, [H, A, Iy, Iz, W])
        data = np.array([H, A, Iy, Iz, W])
        np.savetxt(path/f'{section1}.txt', data, fmt='%d')

    return H, A, Iy, Iz, W



if __name__ == '__main__':
    print(get_rocking_property('HSS12x8x5/16'))



