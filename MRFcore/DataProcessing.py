import os
import sys
import json
import shutil
import time
from pathlib import Path
from math import pi

import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import originpro as op
from originpro import WSheet
from loguru import logger
from scipy.interpolate import interp1d

from MRFcore.WriteOrigin import WriteOrigin


logger.remove()
logger.add(
    sink=sys.stdout,
    format="<green>{time:YYYY-MM-DD HH:mm:ss}</green> <red>|</red> <level>{level}</level> <red>|</red> <level>{message}</level>",
    level="DEBUG"
)


class DataProcessing:
    g = 9810
    span = 3  # 跨数
    
    def __init__(self,
            root: str | Path,
            max_mode: int=None,
            attached_opju: str | Path=None):
        """基于计算后的结果文件夹提取计算结果

        Args:
            root (str | Path): 要读取的文件夹的路径
            max_mode (int, optional): 读取的最大模态数，默认None
            attached_opju (str | Path, optional): origin文件路径，若给定则数据将写入到改文件，若不指定则将创建一个
        """

        self.skip = False
        self.max_mode = max_mode
        self.root = Path(root)
        if attached_opju:
            attached_opju = Path(attached_opju)
            if not attached_opju.suffix == '.opju':
                raise FileNotFoundError('origin文件后缀应为".opju"')
        self.attached_opju = attached_opju
        self._check_data()

    def _check_data(self):
        """检查数据文件是否齐全"""
        list_ = ['ground_motions', 'N', 'running_case']
        for file in list_:
            if not Path.exists(self.root/f'{file}.dat'):
                raise ValueError(f'【Error】未找到{self.root}\\{file}.dat')
        self.GM_names = np.loadtxt(self.root/'ground_motions.dat', dtype=str, ndmin=1).tolist()  # 地震动名
        self.GM_N = len(self.GM_names)
        self.N = int(np.loadtxt(self.root/'N.dat'))  # 楼层数
        with open(self.root/'notes.dat', 'r') as f:
            self.notes = f.read()
        with open(self.root / 'running_case.dat', 'r') as f:
            self.running_case = f.read()
        error_dir = []
        error_Sa = []
        for gm_name in self.GM_names:
            for i in range(1, 10000):
                if Path.exists(self.root/f'{gm_name}_{i}'):
                    print(f'正在检查数据 {gm_name}_{i}    \r', end='')
                    try:
                        pd.read_csv(self.root/f'{gm_name}_{i}/Time.out')
                    except:
                        error_dir.append(str(self.root/f'{gm_name}_{i}'))
                        Sa = np.loadtxt(self.root/f'{gm_name}_{i}/Sa.dat')
                        error_Sa.append(str(np.round(Sa, 10)))
                else:
                    break
        if error_dir:
            error_text = [error_dir[i] + '  Sa = ' + error_Sa[i] for i in range(len(error_Sa))]
            raise ValueError('【Error】以下文件夹无数据：\n' + '\n'.join(error_text))
        logger.success('通过数据文件检查')

    def set_output_dir(self, output_dir: str | Path, cover: int=1):
        """设置输出目录，将提取后的数据存至一个新的文件夹

        Args:
            output_dir (str | Path): 输出目录的绝对路径\n
            cover (int, optional): 当`output_dir`存在时的操作
            * 1: 覆盖
            * 2: 删除原文件夹
            * 3: 退出
        """
        self.root_out = Path(output_dir)
        if self.root == self.root_out:
            logger.error('请注意！输出文件夹与原文件夹相同！')
            raise ValueError('【Error】')
        if not Path.exists(self.root_out):
            os.makedirs(self.root_out)
        else:
            if cover == 1:
                logger.warning(f'将覆盖原有数据')
            elif cover == 2:
                logger.warning('将删除原文件夹')
                shutil.rmtree(output_dir)
                os.makedirs(self.root_out)
            elif cover == 3:
                self.skip = True
                logger.warning('退出程序')
            else:
                logger.error('cover输入值错误')
                raise ValueError('【Error】cover输入值错误')
        np.savetxt(self.root_out/'ground_motions.dat', self.GM_names, fmt='%s')
        np.savetxt(self.root_out/'N.dat', np.array([self.N]))
        with open(self.root_out/'notes.dat', 'w') as f:
            f.write(self.notes)
        with open(self.root_out/'running_case.dat', 'w') as f:
            f.write(self.running_case)
        logger.success(f'已创建输出目录{self.root_out}')

    def read_results(self, *args: str, print_result=True, read_other=True):
        """读取结果

        Args:
            args (str): 要读取的结果类型，包括：  
            * mode：振型、模态  
            * IDR：最大层间位移角，残余层间位移角，层间变形集中系数(DCF)  
            * shear：楼层剪力、基底剪力时程  
            * PFA：楼层加速度包络，屋顶加速度时程  
            * PFV：楼层速度包络， 屋顶速度时程  
            * beamHinge：梁铰变形  
            * columnHinge：柱铰变形  
            * panelZone：节点域变形\n
            print_result (bool, optional): 是否在读取过程中打印结果  
            read_other (bool, optional): 是否读取其他项，默认True
        """
        if self.skip:
            return
        if read_other:
            if not self.running_case in ['PO', 'CP']:
                self._read_other(print_result)
        for result in args:
            if result == 'mode':
                self._read_mode(print_result)
            if self.running_case in ['PO', 'CP']:
                break
            elif result == 'IDR':
                self._read_IDR(print_result)
            elif result == 'shear':
                self._read_shear(print_result)
            elif result == 'PFA':
                self._read_PFA(print_result)
            elif result == 'PFV':
                self._read_PFV(print_result)
            elif result == 'beamHinge':
                self._read_beanHinge(print_result)
            elif result == 'columnHinge':
                self._read_colHinge(print_result)
            elif result == 'panelZone':
                self._read_panelZone(print_result)
            elif result == 'CIDR':
                self._read_CIDR(print_result)
        logger.success('已读取所有数据')

    @staticmethod
    def _mkdir(dir_: Path):
        if not Path.exists(dir_):
            Path.mkdir(dir_)

    @staticmethod
    def _uniform_time_seires(t_gm: np.ndarray, y_gm: np.ndarray, t_new: np.ndarray) -> np.ndarray:
        """将原始的地震动加速度序列转换为可以与计算结果中时间序列对应的新加速度序列

        Args:
            t_gm (np.ndarray): 地震动时间序列
            y_gm (np.ndarray): 地震动加速度序列
            t_new (np.ndarray): 计算结果中的时间序列

        Returns:
            np.ndarray: 新的地震动加速度序列
        """
        # if t_new[-1] < t_gm[-1]:
        #     raise ValueError(f'【Error】计算结果中的时间序列比地震动时间序列短！\n{t_new[-1]} < {t_gm[-1]}')
        if len(t_gm) != len(y_gm):
            raise ValueError(f'【Error】地震动时间序列与地震动加速度长度不一致！\n{len(t_gm)} != {len(y_gm)}')
        linear_interp = interp1d(t_gm, y_gm, kind='linear', fill_value=0, bounds_error=False)
        y_new = linear_interp(t_new)
        return y_new


    def _read_mode(self, print_result: bool):
        """读取模态结果"""
        logger.info('正在读取模态结果...')
        mode = np.zeros((self.N, self.N))  # 每行代表每阶振型
        # self.mode的第i行j列为第i阶振型第j层位移
        if self.running_case == 'IDA':
            subFolder = f'{self.GM_names[0]}_1'
        elif self.running_case == 'PO':
            subFolder = 'Pushover'
        elif self.running_case == 'CP':
            subFolder = 'Cyclic_pushover'
        elif self.running_case == 'TH':
            subFolder = f'{self.GM_names[0]}'
        else:
            raise ValueError(f'未知的`running_case`类型：{self.running_case}')
        T = np.loadtxt(self.root / subFolder / 'Period.out')
        for i in range(self.N):
            mode[i] = np.loadtxt(self.root / subFolder / f'mode{i+1}.out')
            np.savetxt(self.root_out/f'第{i+1}振型.out', mode[i])
            if i + 1 == self.max_mode:
                break
        np.savetxt(self.root_out/'周期(s).out', T)
        if print_result:
            print('周期：', T, sep='')
        logger.success('完成     ')


    def _read_other(self, print_result: bool):
        """读取倒塌状态、时间序列"""
        for idx_gm in range(self.GM_N):
            # 遍历地震动
            gm_name = self.GM_names[idx_gm]
            num =  1
            print(f'    正在读取{gm_name}其他项...({idx_gm+1}/{self.GM_N})     \r', end='')
            while True:
                # 遍历每个动力增量
                subfolder = f'{gm_name}_{num}' if self.running_case == 'IDA' else gm_name
                folder = self.root / subfolder
                if not Path.exists(folder):
                    break
                data = np.loadtxt(folder / f'isCollapsed.dat')
                self._mkdir(self.root_out/subfolder)
                np.savetxt(self.root_out/subfolder/'倒塌判断.out', np.array([data]), fmt='%d')
                t = np.loadtxt(folder/'Time.out')[11:, 0]
                t = np.round(t, 6)
                np.savetxt(self.root_out/subfolder/'时间序列.out', t, fmt='%f')
                if self.running_case == 'IDA':
                    data = np.loadtxt(folder / f'Sa.dat')
                    data = np.round(data, 6)
                    np.savetxt(self.root_out/subfolder/'Sa.out', np.array([data]))
                num += 1
                if self.running_case == 'TH':
                    break
        
    def _read_IDR(self, print_result: bool):
        """读取最大层间位移角，残余层间位移角"""
        logger.info('正在读取层间位移角...')
        for idx_gm in range(self.GM_N):
            # 遍历地震动
            gm_name = self.GM_names[idx_gm]
            num =  1
            print(f'    正在读取{gm_name}层间位移角...({idx_gm+1}/{self.GM_N})     \r', end='')
            while True:
                # 遍历每个动力增量
                subfolder = f'{gm_name}_{num}' if self.running_case == 'IDA' else gm_name
                folder = self.root / subfolder
                IDR = np.zeros(self.N + 1)
                IDR_res = np.zeros(self.N + 1)
                if not Path.exists(folder):
                    break
                IDR_roof = np.array([max(abs(np.loadtxt(folder / f'SDR_Roof.out')))])  # 屋顶位移角
                for story in range(1, self.N + 1):
                    # 遍历楼层
                    data = pd.read_csv(folder / f'SDR{story}.out', header=None).to_numpy()[:, 0]  # 层间位移角
                    data_max= max(abs(data))
                    data_res = data[-1]
                    IDR[story] = data_max
                    IDR_res[story] = data_res
                self._mkdir(self.root_out/subfolder)
                np.savetxt(self.root_out/subfolder/'层间位移角.out', IDR)
                np.savetxt(self.root_out/subfolder/'残余层间位移角.out', IDR_res)
                np.savetxt(self.root_out/subfolder/'屋顶层间位移角.out', IDR_roof)
                np.savetxt(self.root_out/subfolder/'DCF.out', max(IDR) / IDR_roof)  # 层间变形集中系数
                roof_d = pd.read_csv(folder/f'Disp{self.N+1}.out', header=None).to_numpy()[11:, 0]
                np.savetxt(self.root_out/subfolder/'屋顶位移时程(相对).out', roof_d, fmt='%.4f')
                num += 1
                if self.running_case == 'TH':
                    break
        logger.success('完成     ')

    @staticmethod
    def _get_cumulative_results(list_: list | np.ndarray) -> float:
        """获取可迭代对象的累积增量值

        Args:
            list_ (list | np.ndaray): 列表数据

        Returns:
            float: 累积增量值
        """
        result = 0
        for i in range(1, len(list_)):
            result += abs(list_[i] - list_[i-1])
        return result
        

    def _read_CIDR(self, print_result: bool):
        """读取累积层间位移角"""
        logger.info('正在计算累积层间位移角...')
        for idx_gm in range(self.GM_N):
            # 遍历地震动
            gm_name = self.GM_names[idx_gm]
            num =  1
            print(f'    正在计算{gm_name}累积层间位移角...({idx_gm+1}/{self.GM_N})     \r', end='')
            while True:
                # 遍历每个动力增量
                subfolder = f'{gm_name}_{num}' if self.running_case == 'IDA' else gm_name
                folder = self.root / subfolder
                CIDR = np.zeros(self.N + 1)
                if not Path.exists(folder):
                    break
                for story in range(1, self.N + 1):
                    # 遍历楼层
                    data = pd.read_csv(folder / f'SDR{story}.out', header=None).to_numpy()[:, 0]
                    data_c= self._get_cumulative_results(data)
                    CIDR[story] = data_c
                self._mkdir(self.root_out/subfolder)
                np.savetxt(self.root_out/subfolder/'累积层间位移角.out', CIDR)
                num += 1
                if self.running_case == 'TH':
                    break
        logger.success('完成     ')
        
    def _read_shear(self, print_result: bool):
        """读取层剪力、底部剪力时程"""
        logger.info('正在计算楼层剪力...')
        for idx_gm in range(self.GM_N):
            # 遍历地震动
            gm_name = self.GM_names[idx_gm]
            num =  1
            print(f'    正在计算{gm_name}层剪力...({idx_gm+1}/{self.GM_N})     \r', end='')
            while True:
                # 遍历每个动力增量
                subfolder = f'{gm_name}_{num}' if self.running_case == 'IDA' else gm_name
                folder = self.root / subfolder
                shear = np.zeros(self.N)
                if not Path.exists(folder):
                    break
                for story in range(1, self.N + 1):
                    # 遍历楼层
                    shear_story = None
                    for file in folder.iterdir():
                        if f'Shear{story}_' in file.name:
                            data = np.loadtxt(file)[:, 0] / 1000
                            if shear_story is not None:
                                shear_story += data
                            else:
                                shear_story = data
                    shear_story = max(abs(shear_story))
                    shear[story - 1] = shear_story
                self._mkdir(self.root_out/subfolder)
                np.savetxt(self.root_out/subfolder/'楼层剪力(kN).out', shear)
                num += 1
                if self.running_case == 'TH':
                    break
        logger.success('完成     ')

    @staticmethod
    def _get_gm(path_: str | Path, gm_name, suffix='.txt') -> tuple[np.ndarray, float]:
        path_ = Path(path_)
        with open(path_/'GM_info.json', 'r') as f:
            dt_dict = json.loads(f.read())
        dt = dt_dict[gm_name]
        th = np.loadtxt(f'{path_}/{gm_name}{suffix}')
        # t = np.arange(0, len(th) * dt, dt)
        t = np.linspace(0, (len(th) - 1) * dt, len(th))
        return th, t

    def _read_PFA(self, print_result: bool):
        """读取楼层绝对加速度包络，屋顶加速度时程"""
        logger.info('正在读取楼层绝对加速度...')
        for idx_gm in range(self.GM_N):
            # 遍历地震动
            gm_name = self.GM_names[idx_gm]
            num =  1
            print(f'    正在读取{gm_name}楼层加速度...({idx_gm+1}/{self.GM_N})     \r', end='')
            while True:
                # 遍历每个动力增量
                subfolder = f'{gm_name}_{num}' if self.running_case == 'IDA' else gm_name
                folder = self.root / subfolder
                a_base = np.loadtxt(folder / 'groundmotion.out')  # 基底绝对加速度
                PFA = np.zeros(self.N)
                if not Path.exists(folder):
                    break
                t = np.loadtxt(folder/'Time.out')[:, 0]  # 计算结果中的时序
                for story in range(1, self.N + 1):
                    # 遍历楼层
                    data = np.loadtxt(folder / f'RFA{story+1}.out')[10:]  # 楼层相对加速度
                    data += a_base  # 转换为绝对加速度
                    data_max= max(abs(data)) / self.g
                    PFA[story - 1] = data_max
                self._mkdir(self.root_out/subfolder)
                np.savetxt(self.root_out/subfolder/'层加速度(g).out', PFA)
                a_roof = np.loadtxt(folder/f'RFA{self.N+1}.out')[10:] / self.g  # 屋顶相对加速度
                a_roof += a_base  # 屋顶绝对加速度
                np.savetxt(self.root_out/subfolder/'屋顶加速度时程(绝对)(g).out', a_roof)
                num += 1
                if self.running_case == 'TH':
                    break
        logger.success('完成     ')

    @staticmethod
    def _get_v(a: np.ndarray, t:np.ndarray) -> np.ndarray:
        """对加速度序列进行积分，得到速度

        Args:
            a (np.ndarray): 加速度
            t (np.ndarray): 时间序列

        Returns:
            np.ndarray: 速度序列
        """
        if len(t) != len(a):
            raise ValueError(f'【Error】加速度时程和时间序列长度不一致！（{len(a)}, {len(t)}）')
        v = np.array([0])
        for i in range(len(a) - 1):
            dt = t[i + 1] - t[i]
            S = (a[i] + a[i+1]) * dt / 2
            v_new = v[-1] + S
            v = np.append(v, v_new)
        return v


    def _read_PFV(self, print_result: bool):
        """读取楼层相对速度"""
        logger.info('正在读取楼层相对速度...')
        for idx_gm in range(self.GM_N):
            # 遍历地震动
            gm_name = self.GM_names[idx_gm]
            num =  1
            print(f'    正在读取{gm_name}楼层速度...({idx_gm+1}/{self.GM_N})     \r', end='')
            while True:
                # 遍历每个动力增量
                subfolder = f'{gm_name}_{num}' if self.running_case == 'IDA' else gm_name
                folder = self.root / subfolder
                PFV = np.zeros(self.N)
                if not Path.exists(folder):
                    break
                for story in range(1, self.N + 1):
                    # 遍历楼层
                    data = np.loadtxt(folder / f'RFV{story+1}.out')
                    data_max = max(abs(data))
                    PFV[story - 1] = data_max
                self._mkdir(self.root_out/subfolder)
                np.savetxt(self.root_out/subfolder/'层速度.out', PFV)
                v_roof = np.loadtxt(folder/f'RFV{self.N+1}.out')[11:]
                np.savetxt(self.root_out/subfolder/'屋顶速度时程(相对).out', v_roof)
                num += 1
                if self.running_case == 'TH':
                    break
        logger.success('完成     ')

    def _read_beanHinge(self, print_result: bool):
        """读取梁铰  
        行数=楼层数，列数=柱子数，
        每一行中，从左到右依次为：
        左边柱右侧梁铰→中柱两侧梁铰→右边柱左侧梁铰。
        即梁铰顺序是从左到右的
        """
        logger.info('正在读取梁铰变形...')
        for idx_gm in range(self.GM_N):
            # 遍历地震动
            gm_name = self.GM_names[idx_gm]
            num =  1
            print(f'    正在读取{gm_name}梁铰变形...({idx_gm+1}/{self.GM_N})     \r', end='')
            while True:
                # 遍历每个动力增量
                subfolder = f'{gm_name}_{num}' if self.running_case == 'IDA' else gm_name
                folder = self.root / subfolder
                if not Path.exists(folder):
                    break
                hinge_result = np.zeros((self.N, self.span * 2))
                for story in range(1, self.N + 1):
                    # 遍历楼层
                    for col in range(1, self.span + 2):
                        # 遍历柱 1 ~ 柱数
                        if col == 1:
                            # 左边柱
                            theta_r = np.loadtxt(folder/f'BeamSpring{story+1}_{col}R.out')[:, 1]
                            theta_r = max(abs(theta_r))
                            hinge_result[story-1, 0] = theta_r
                        elif col == self.span + 1:
                            # 右边柱
                            theta_l = np.loadtxt(folder/f'BeamSpring{story+1}_{col}L.out')[:, 1]
                            theta_l = max(abs(theta_l))
                            hinge_result[story-1, -1] = theta_l
                        else:
                            # 中间的柱
                            theta_l = np.loadtxt(folder/f'BeamSpring{story+1}_{col}L.out')[:, 1]
                            theta_r = np.loadtxt(folder/f'BeamSpring{story+1}_{col}R.out')[:, 1]
                            theta_l, theta_r = max(abs(theta_l)), max(abs(theta_r))
                            hinge_result[story-1, 1+(col-2)*2] = theta_l
                            hinge_result[story-1, 2+(col-2)*2] = theta_r
                np.savetxt(self.root_out/subfolder/'梁铰变形.out', hinge_result, fmt='%.6f')
                num += 1
                if self.running_case == 'TH':
                    break
        logger.success('完成     ')

    def _read_colHinge(self, print_result: bool):
        """
        读取柱铰  
        行数=层数*2，列数=柱子数，每一列中，随行数增大柱铰的实际位置顺序从下到上        
        """
        # 
        logger.info('正在读取柱铰变形...')
        for idx_gm in range(self.GM_N):
            # 遍历地震动
            gm_name = self.GM_names[idx_gm]
            num =  1
            print(f'    正在读取{gm_name}柱铰变形...({idx_gm+1}/{self.GM_N})     \r', end='')
            while True:
                # 遍历每个动力增量
                subfolder = f'{gm_name}_{num}' if self.running_case == 'IDA' else gm_name
                folder = self.root / subfolder
                if not Path.exists(folder):
                    break
                hinge_result = np.zeros((self.N * 2, self.span + 1))
                for story in range(1, self.N + 2):
                    # 遍历楼层 1-5
                    for col in range(1, self.span + 2):
                        # 遍历柱 1-4
                        # M_l = np.loadtxt(folder/f'BeamSpring{story+1}{span}L_F.out')
                        # M_r = np.loadtxt(folder/f'BeamSpring{story+1}{span}R_F.out')
                        if story == 1:
                            # 首层（地面）
                            theta_T = np.loadtxt(folder/f'ColSpring{story}_{col}T.out')[:, 1]
                            theta_T = max(abs(theta_T))
                            hinge_result[0, col-1] = theta_T
                        elif story == self.N + 1:
                            # 顶层
                            theta_B = np.loadtxt(folder/f'ColSpring{story}_{col}B.out')[:, 1]
                            theta_B = max(abs(theta_B))
                            hinge_result[-1, col-1] = theta_B
                        else:
                            # 中间层
                            theta_B = np.loadtxt(folder/f'ColSpring{story}_{col}B.out')[:, 1]
                            theta_T = np.loadtxt(folder/f'ColSpring{story}_{col}T.out')[:, 1]
                            theta_B, theta_T = max(abs(theta_B)), max(abs(theta_T))
                            hinge_result[2*(story-2)+1, col-1] = theta_B
                            hinge_result[2*(story-2)+2, col-1] = theta_T
                np.savetxt(self.root_out/subfolder/'柱铰变形.out', hinge_result, fmt='%.6f')
                num += 1
                if self.running_case == 'TH':
                    break
        logger.success('完成     ')

    def _read_panelZone(self, print_result: bool):
        """
        读取节点域  
        行数=层数，列数=柱子数，每一列中，随行数增大节点的实际位置顺序从下到上        
        """
        logger.info('正在读取节点域变形...')
        for idx_gm in range(self.GM_N):
            # 遍历地震动
            gm_name = self.GM_names[idx_gm]
            num =  1
            print(f'    正在读取{gm_name}节点域变形...({idx_gm+1}/{self.GM_N})     \r', end='')
            while True:
                # 遍历每个动力增量
                subfolder = f'{gm_name}_{num}' if self.running_case == 'IDA' else gm_name
                folder = self.root / subfolder
                if not Path.exists(folder):
                    break
                hinge_result = np.zeros((self.N, self.span + 1))
                for story in range(2, self.N + 2):
                    # 遍历楼层 2-5
                    for col in range(1, self.span + 2):
                        theta = np.loadtxt(folder/f'PZ{story}_{col}.out')[:, 1]
                        theta = max(abs(theta))
                        hinge_result[story-2, col-1] = theta
                np.savetxt(self.root_out/subfolder/'节点域变形.out', hinge_result, fmt='%.6f')
                num += 1
                if self.running_case == 'TH':
                    break
        logger.success('完成     ')

    @staticmethod
    def _get_x(x: list, y: list, y0: float) -> float:
        """获得横线y=y0与给定曲线的交点横坐标

        Args:
            x (list): 输入曲线的横坐标序列\n
            y (list): 输入曲线的纵坐标序列\n
            y0 (float): 横直线y = y0\n

        Returns:
            float: 曲线与横线交点横坐标
        """
        if y0 < min(y):
            raise ValueError(f'【Error】y0 < min(y) ({y0} < {min(y)})')
        if y0 > max(y):
            raise ValueError(f'【Error】y0 > max(y) ({y0} > {max(y)})')
        for i in range(len(y) - 1):
            if y[i] == y0:
                x0 = x[i]
                return x0
            elif y[i] < y0 <= y[i + 1] or y[i] > y0 >= y[i + 1]:
                k = (y[i + 1] - y[i]) / (x[i + 1] - x[i])
                x0 = x[i] + (y0 - y[i]) / k
                return x0
        else:
            raise ValueError('【Error】未找到交点-1')

    @staticmethod
    def _get_ductility(x: np.ndarray, y: np.ndarray) -> float:
        """获取推覆曲线的延性系数"""
        y_max = max(y)
        idx_y_max = np.argmax(y)
        y_k = 0.4 * y_max
        x_k = DataProcessing._get_x(x, y, y_k)
        K = y_k / x_k  # 推覆曲线的初始刚度
        delta_yeff = y_max / K  # 屈服位移
        delta_u = DataProcessing._get_x(x[idx_y_max:], y[idx_y_max:], 0.8 * y_max)
        miu = delta_u / delta_yeff
        return miu
        
    def read_pushover(self, H: float, FDR_step=[0.01*i for i in range(1, 11)], plot_result=True):
        """读取pushover结果，计算应力

        Args:
            H (float): 结构总高度
            FDR_step (list, optional): 不同级别的屋顶位移角，用于计算不同屋顶位移角下结构的归一化层位移
            plot_result (bool, optional): 是否绘制曲线（默认True）
        """
        if self.running_case != 'PO':
            logger.warning('文件夹中存放的不是pushover分析结果')
            return
        logger.info('正在读取pushover结果...')
        Time = np.loadtxt(self.root/'pushover/Time.out')[11:]
        n = len(Time)
        PO_path = self.root / 'pushover'
        # 底部重力
        weight = 0
        for item in PO_path.iterdir():
            if item.is_file() and 'Support' in str(item):
                weight += np.loadtxt(item)[10, 1] / 1000
        print(f'weight = {weight:.3f} kN')
        # 底部剪力
        shear = np.zeros(n)
        for item in PO_path.iterdir():
            if item.is_file() and 'Support' in str(item):
                shear += np.loadtxt(item)[11:, 0]
        if abs(min(shear[:100])) > abs(max(shear[:100])):
            shear *= -1  # 将推覆方向始终设为正向
        # 各层位移
        u = np.zeros((self.N, n))
        for i in range(self.N):
            u[i] = np.loadtxt(self.root/'pushover'/f'Disp{i+2}.out')[11:]
        # 层间位移角
        IDR = np.zeros((self.N, n))
        for i in range(self.N):
            IDR[i] = np.loadtxt(self.root/'pushover'/f'SDR{i+1}.out')[11:]
        # 归一化楼层位移角(各层位移除以结构总高)
        FDR = np.zeros((self.N, n))
        for i in range(self.N):
            FDR[i] = u[i] / H
        # 不同最大屋顶位移角时的最大层间位移角曲线
        step = 0
        FDR_lines = []
        for i in range(n - 1):
            if FDR[-1, i] <= FDR_step[step] < FDR[-1, i+1]:
                FDR_step_add = np.amax(FDR[:, :i+1], axis=1)
                FDR_step_add = np.insert(FDR_step_add, 0, 0)
                FDR_lines.append(FDR_step_add)
                step += 1
                if step == len(FDR_step):
                    break
        # 推覆曲线
        x_pushover = FDR[-1] * 100
        if weight:
            y_pushover = shear / weight
            label = 'Norminal base shear force'
        else:
            y_pushover = shear
            label = 'Base shear force (kN)'
        curve_pushover = np.array([x_pushover, y_pushover]).T
        ductility = self._get_ductility(x_pushover, y_pushover)
        np.savetxt(self.root_out/'屋顶位移角-基底剪力.txt', curve_pushover)
        np.savetxt(self.root_out/'延性系数.txt', np.array([ductility]), fmt='%.6f')
        print(f'最大基底剪力：{max(y_pushover):.3f}')
        print(f'延性系数：{ductility:.3f}')
        # 画图
        if plot_result:
            plt.subplot(121)
            plt.plot(x_pushover, y_pushover)
            plt.xlabel('Roof drift (%)')
            plt.ylabel(label)
            plt.title('Roof drift - shear force')
            plt.xlim(0)
            plt.ylim(0)
            plt.subplot(122)
            data = np.zeros((self.N + 1, len(FDR_lines) * 2))
            for i, FDR_line in enumerate(FDR_lines):
                plt.plot(FDR_line * 100, np.arange(1, self.N + 2, 1), '-o', label=f'{round(FDR_step[i]*100, 0)}%')
                data[:, i*2] = FDR_line * 100
                data[:, i*2+1] = np.arange(1, self.N + 2, 1)
            np.savetxt(self.root_out/'归一化屋顶位移曲线.txt', data)
            plt.legend()
            plt.xlabel('Nominal floor displacement (%)')
            plt.ylabel('Floor')
            plt.show()
        logger.success('完成     ')


    def read_cyclic_pushover(self, H: float,  plot_result=True):
        """读取循环pushover分析结果

        Args:
            H (float): 结构总高度
            plot_result (bool, optional): 是否绘制曲线（默认True）
        """
        if self.running_case != 'CP':
            logger.warning('文件夹中存放的不是cyclic pushover分析结果')
            return
        logger.info('正在读取cyclic pushover结果...')
        CP_path = self.root / 'Cyclic_pushover'
        Time = np.loadtxt(CP_path / 'Time.out')[11:]
        n = len(Time)
        # 底部重力
        weight = 0
        for item in CP_path.iterdir():
            if item.is_file() and 'Support' in str(item):
                weight += np.loadtxt(item)[10, 1] / 1000
        print(f'weight = {weight:.3f} kN')
        # 底部剪力
        shear = np.zeros(n)
        for item in CP_path.iterdir():
            if item.is_file() and 'Support' in str(item):
                shear += np.loadtxt(item)[11:, 0] / 1000
        if abs(min(shear[:20])) > abs(max(shear[:20])):
            shear *= -1
        # 归一化楼层位移角(各层位移除以结构总高)
        RDR = np.loadtxt(CP_path / f'SDR_Roof.out')[11:]
        # cyclic pushover滞回曲线
        x_cp = RDR * 100
        y_cp = shear / weight * 100
        # 输出
        np.savetxt(self.root_out/'屋顶位移角-基底剪力(kN).txt', np.column_stack((RDR, shear)))
        np.savetxt(self.root_out/'屋顶位移角(%)-归一化基底剪力(%).txt', np.column_stack((x_cp, y_cp)))
        # 画图
        if plot_result:
            plt.subplot(121)
            plt.title('Roof drift - shear force')
            plt.plot(RDR, shear)
            plt.xlabel('Roof drift ratio')
            plt.ylabel('Base shear (kN)')
            plt.subplot(122)
            plt.title('Roof drift - norm. shear force')
            plt.plot(x_cp, y_cp)
            plt.xlabel('Roof drift ratio (%)')
            plt.ylabel('Norm. base shear (%)')
            plt.show()
        logger.success('完成     ')

    def read_th(self):
        """读取时程分析"""
        if not self.running_case == 'TH':
            logger.warning('【Error】方法read_th仅限用于时程分析工况')
            return
        if not Path(self.root_out/'结果统计').exists():
            Path.mkdir(self.root_out/'结果统计')
        IDR = np.zeros((self.N + 1, self.GM_N))  # 最大层间位移角
        IDR_stat = np.zeros((self.N + 1, 5))  # 均值，标准差，16,50,84分位数
        IDRroof = np.zeros(self.GM_N)  # 屋顶层间位移角
        IDRroof_stat = np.zeros(5)  # 均值，标准差，16,50,84分位数
        DCF = np.zeros(self.GM_N)  # 层间位移角集中系数
        DCF_stat = np.zeros(5)  # 均值，标准差，16,50,84分位数
        Shear = np.zeros((self.N, self.GM_N))  # 最大楼层剪力
        Shear_stat = np.zeros((self.N, 5))  # 均值，标准差，16,50,84分位数
        CIDR = np.zeros((self.N + 1, self.GM_N))  # 累积层间位移角
        CIDR_stat = np.zeros((self.N + 1, 5))  # 均值，标准差，16,50,84分位数
        PFV = np.zeros((self.N, self.GM_N))  # 最大层间位速度
        PFV_stat = np.zeros((self.N, 5))  # 均值，标准差，16,50,84分位数
        PFA = np.zeros((self.N, self.GM_N))  # 最大层加速度
        PFA_stat = np.zeros((self.N, 5))  # 均值，标准差，16,50,84分位数
        RIDR = np.zeros((self.N + 1, self.GM_N))  # 最大层间位移角
        RIDR_stat = np.zeros((self.N + 1, 5))  # 均值，标准差，16,50,84分位数
        beam_hinge = np.zeros((self.GM_N, self.N, self.span * 2))  # 梁铰变形
        beam_hinge_stat = np.zeros((5, self.N, self.span * 2))
        col_hinge = np.zeros((self.GM_N, self.N * 2, self.span + 1))  # 柱铰变形
        col_hinge_stat = np.zeros((5, self.N * 2, self.span + 1))
        panel_zone = np.zeros((self.GM_N, self.N, self.span + 1))  # 节点域变形
        panel_zone_stat = np.zeros((5, self.N, self.span + 1))
        def MyLoadtxt(path: Path, array: np.ndarray):
            try:
                res = np.loadtxt(path)
            except:
                res = array
            return res
        for idx_gm, gm_name in enumerate(self.GM_names):
            # 倒塌判断
            clps = np.loadtxt(self.root_out/gm_name/'倒塌判断.out')
            if clps == 1:
                logger.warning(f'{gm_name}发生倒塌！')
            # 最大层间位移角
            IDR[:, idx_gm] = MyLoadtxt(self.root_out/gm_name/'层间位移角.out', IDR[:, idx_gm])
            # 屋顶位移角
            IDRroof[idx_gm] = MyLoadtxt(self.root_out/gm_name/'屋顶层间位移角.out', IDRroof[idx_gm])
            # 层间位移角集中系数
            DCF[idx_gm] = MyLoadtxt(self.root_out/gm_name/'DCF.out', DCF[idx_gm])
            # 最大楼层剪力
            Shear[:, idx_gm] = MyLoadtxt(self.root_out/gm_name/'楼层剪力(kN).out', Shear[:, idx_gm])
            # 累积层间位移角
            CIDR[:, idx_gm] = MyLoadtxt(self.root_out/gm_name/'累积层间位移角.out', CIDR[:, idx_gm])
            # 层速度
            PFV[:, idx_gm] = MyLoadtxt(self.root_out/gm_name/'层速度.out', PFV[:, idx_gm])
            # 层加速度
            PFA[:, idx_gm] = MyLoadtxt(self.root_out/gm_name/'层加速度(g).out', PFA[:, idx_gm])
            # 残余层间位移角
            RIDR[:, idx_gm] = abs(MyLoadtxt(self.root_out/gm_name/'残余层间位移角.out', RIDR[:, idx_gm]))
            # 梁铰变形
            beam_hinge[idx_gm] = MyLoadtxt(self.root_out/gm_name/'梁铰变形.out', beam_hinge[idx_gm])
            # 柱铰变形
            col_hinge[idx_gm] = MyLoadtxt(self.root_out/gm_name/'柱铰变形.out', col_hinge[idx_gm])
            # 节点域变形
            panel_zone[idx_gm] = MyLoadtxt(self.root_out/gm_name/'节点域变形.out', panel_zone[idx_gm])
        # 计算统计特性
        IDR_stat[:, 0] = np.mean(IDR, axis=1)
        IDR_stat[:, 1] = np.std(IDR, axis=1)
        IDR_stat[:, 2] = np.percentile(IDR, 16, axis=1)
        IDR_stat[:, 3] = np.percentile(IDR, 50, axis=1)
        IDR_stat[:, 4] = np.percentile(IDR, 84, axis=1)
        IDRroof_stat[0] = np.mean(IDRroof)
        IDRroof_stat[1] = np.std(IDRroof)
        IDRroof_stat[2] = np.percentile(IDRroof, 16)
        IDRroof_stat[3] = np.percentile(IDRroof, 50)
        IDRroof_stat[4] = np.percentile(IDRroof, 84)
        DCF_stat[0] = np.mean(DCF)
        DCF_stat[1] = np.std(DCF)
        DCF_stat[2] = np.percentile(DCF, 16)
        DCF_stat[3] = np.percentile(DCF, 50)
        DCF_stat[4] = np.percentile(DCF, 84)
        Shear_stat[:, 0] = np.mean(Shear, axis=1)
        Shear_stat[:, 1] = np.std(Shear, axis=1)
        Shear_stat[:, 2] = np.percentile(Shear, 16, axis=1)
        Shear_stat[:, 3] = np.percentile(Shear, 50, axis=1)
        Shear_stat[:, 4] = np.percentile(Shear, 80, axis=1)
        CIDR_stat[:, 0] = np.mean(CIDR, axis=1)
        CIDR_stat[:, 1] = np.std(CIDR, axis=1)
        CIDR_stat[:, 2] = np.percentile(CIDR, 16, axis=1)
        CIDR_stat[:, 3] = np.percentile(CIDR, 50, axis=1)
        CIDR_stat[:, 4] = np.percentile(CIDR, 84, axis=1)
        PFV_stat[:, 0] = np.mean(PFV, axis=1)
        PFV_stat[:, 1] = np.std(PFV, axis=1)
        PFV_stat[:, 2] = np.percentile(PFV, 16, axis=1)
        PFV_stat[:, 3] = np.percentile(PFV, 50, axis=1)
        PFV_stat[:, 4] = np.percentile(PFV, 84, axis=1)
        PFA_stat[:, 0] = np.mean(PFA, axis=1)
        PFA_stat[:, 1] = np.std(PFA, axis=1)
        PFA_stat[:, 2] = np.percentile(PFA, 16, axis=1)
        PFA_stat[:, 3] = np.percentile(PFA, 50, axis=1)
        PFA_stat[:, 4] = np.percentile(PFA, 84, axis=1)
        RIDR_stat[:, 0] = np.mean(RIDR, axis=1)
        RIDR_stat[:, 1] = np.std(RIDR, axis=1)
        RIDR_stat[:, 2] = np.percentile(RIDR, 16, axis=1)
        RIDR_stat[:, 3] = np.percentile(RIDR, 50, axis=1)
        RIDR_stat[:, 4] = np.percentile(RIDR, 84, axis=1)
        beam_hinge_stat[0] = np.mean(beam_hinge, axis=0)
        beam_hinge_stat[1] = np.std(beam_hinge, axis=0)
        beam_hinge_stat[2] = np.percentile(beam_hinge, 16, axis=0)
        beam_hinge_stat[3] = np.percentile(beam_hinge, 50, axis=0)
        beam_hinge_stat[4] = np.percentile(beam_hinge, 84, axis=0)
        col_hinge_stat[0] = np.mean(col_hinge, axis=0)
        col_hinge_stat[1] = np.std(col_hinge, axis=0)
        col_hinge_stat[2] = np.percentile(col_hinge, 16, axis=0)
        col_hinge_stat[3] = np.percentile(col_hinge, 50, axis=0)
        col_hinge_stat[4] = np.percentile(col_hinge, 84, axis=0)
        panel_zone_stat[0] = np.mean(panel_zone, axis=0)
        panel_zone_stat[1] = np.std(panel_zone, axis=0)
        panel_zone_stat[2] = np.percentile(panel_zone, 16, axis=0)
        panel_zone_stat[3] = np.percentile(panel_zone, 50, axis=0)
        panel_zone_stat[4] = np.percentile(panel_zone, 84, axis=0)
        # 保存结果
        columns = ['均值', '标准差', '16th', '50th', '84th']
        IDR = pd.DataFrame(IDR, index=range(0, self.N + 1), columns=self.GM_names)
        IDRroof = pd.DataFrame([IDRroof], columns=self.GM_names)
        DCF = pd.DataFrame([DCF], columns=self.GM_names)
        Shear = pd.DataFrame(Shear, index=range(1, self.N + 1), columns=self.GM_names)
        CIDR = pd.DataFrame(CIDR, index=range(0, self.N + 1), columns=self.GM_names)
        PFV = pd.DataFrame(PFV, index=range(1, self.N + 1), columns=self.GM_names)
        PFA = pd.DataFrame(PFA, index=range(1, self.N + 1), columns=self.GM_names)
        RIDR = pd.DataFrame(RIDR, index=range(0, self.N + 1), columns=self.GM_names)
        IDR_stat = pd.DataFrame(IDR_stat, index=range(0, self.N + 1), columns=columns)
        IDRroof_stat = pd.DataFrame([IDRroof_stat], columns=columns)
        DCF_stat = pd.DataFrame([DCF_stat], columns=columns)
        Shear_stat = pd.DataFrame(Shear_stat, index=range(1, self.N + 1), columns=columns)
        CIDR_stat = pd.DataFrame(CIDR_stat, index=range(0, self.N + 1), columns=columns)
        PFV_stat = pd.DataFrame(PFV_stat, index=range(1, self.N + 1), columns=columns)
        PFA_stat = pd.DataFrame(PFA_stat, index=range(1, self.N + 1), columns=columns)
        RIDR_stat = pd.DataFrame(RIDR_stat, index=range(0, self.N + 1), columns=columns)
        columns_beam = ['左', '右'] * self.span
        beam_hinge_stat_mean = pd.DataFrame(beam_hinge_stat[0], index=range(1, self.N + 1), columns=columns_beam)
        beam_hinge_stat_std = pd.DataFrame(beam_hinge_stat[1], index=range(1, self.N + 1), columns=columns_beam)
        beam_hinge_stat_16th = pd.DataFrame(beam_hinge_stat[2], index=range(1, self.N + 1), columns=columns_beam)
        beam_hinge_stat_50th = pd.DataFrame(beam_hinge_stat[3], index=range(1, self.N + 1), columns=columns_beam)
        beam_hinge_stat_84th = pd.DataFrame(beam_hinge_stat[4], index=range(1, self.N + 1), columns=columns_beam)
        index_col = sum([[f'{i}下', f'{i}上'] for i in range(1, self.N + 1)], [])
        col_hinge_stat_mean = pd.DataFrame(col_hinge_stat[0], index=index_col, columns=range(1, self.span + 2))
        col_hinge_stat_std = pd.DataFrame(col_hinge_stat[1], index=index_col, columns=range(1, self.span + 2))
        col_hinge_stat_16th = pd.DataFrame(col_hinge_stat[2], index=index_col, columns=range(1, self.span + 2))
        col_hinge_stat_50th = pd.DataFrame(col_hinge_stat[3], index=index_col, columns=range(1, self.span + 2))
        col_hinge_stat_84th = pd.DataFrame(col_hinge_stat[4], index=index_col, columns=range(1, self.span + 2))
        index_panel = range(1, self.N + 1)
        panel_zone_stat_mean = pd.DataFrame(panel_zone_stat[0], index=index_panel, columns=range(1, self.span + 2))
        panel_zone_stat_std = pd.DataFrame(panel_zone_stat[1], index=index_panel, columns=range(1, self.span + 2))
        panel_zone_stat_16th = pd.DataFrame(panel_zone_stat[2], index=index_panel, columns=range(1, self.span + 2))
        panel_zone_stat_50th = pd.DataFrame(panel_zone_stat[3], index=index_panel, columns=range(1, self.span + 2))
        panel_zone_stat_84th = pd.DataFrame(panel_zone_stat[4], index=index_panel, columns=range(1, self.span + 2))
        IDR.to_csv(self.root_out/'结果统计'/'层间位移角.csv', encoding='ANSI', float_format='%.6f')
        IDRroof.to_csv(self.root_out/'结果统计'/'屋顶层间位移角.csv', encoding='ANSI', float_format='%.6f')
        DCF.to_csv(self.root_out/'结果统计'/'DCF.csv', encoding='ANSI', float_format='%.6f')
        Shear.to_csv(self.root_out/'结果统计'/'楼层剪力(kN).csv', encoding='ANSI', float_format='%.2f')
        CIDR.to_csv(self.root_out/'结果统计'/'累积层间位移角.csv', encoding='ANSI', float_format='%.6f')
        PFV.to_csv(self.root_out/'结果统计'/'层速度(mm_s).csv', encoding='ANSI', float_format='%.2f')
        PFA.to_csv(self.root_out/'结果统计'/'层加速度(g).csv', encoding='ANSI', float_format='%.4f')
        RIDR.to_csv(self.root_out/'结果统计'/'残余层间位移角.csv', encoding='ANSI', float_format='%.6f')
        IDR_stat.to_csv(self.root_out/'结果统计'/'层间位移角_统计.csv', encoding='ANSI', float_format='%.6f')
        IDRroof_stat.to_csv(self.root_out/'结果统计'/'屋顶层间位移角_统计.csv', encoding='ANSI', float_format='%.6f')
        DCF_stat.to_csv(self.root_out/'结果统计'/'DCF_统计.csv', encoding='ANSI', float_format='%.6f')
        Shear_stat.to_csv(self.root_out/'结果统计'/'楼层剪力_统计.csv', encoding='ANSI', float_format='%.2f')
        CIDR_stat.to_csv(self.root_out/'结果统计'/'累积层间位移角_统计.csv', encoding='ANSI', float_format='%.6f')
        PFV_stat.to_csv(self.root_out/'结果统计'/'层速度_统计.csv', encoding='ANSI', float_format='%.2f')
        PFA_stat.to_csv(self.root_out/'结果统计'/'层加速度_统计.csv', encoding='ANSI', float_format='%.4f')
        RIDR_stat.to_csv(self.root_out/'结果统计'/'残余层间位移角_统计.csv', encoding='ANSI', float_format='%.6f')
        beam_hinge_stat_mean.to_csv(self.root_out/'结果统计'/'梁铰_统计_mean.csv', encoding='ANSI', float_format='%.6f')
        beam_hinge_stat_std.to_csv(self.root_out/'结果统计'/'梁铰_统计_std.csv', encoding='ANSI', float_format='%.6f')
        beam_hinge_stat_16th.to_csv(self.root_out/'结果统计'/'梁铰_统计_16th.csv', encoding='ANSI', float_format='%.6f')
        beam_hinge_stat_50th.to_csv(self.root_out/'结果统计'/'梁铰_统计_50th.csv', encoding='ANSI', float_format='%.6f')
        beam_hinge_stat_84th.to_csv(self.root_out/'结果统计'/'梁铰_统计_84th.csv', encoding='ANSI', float_format='%.6f')
        col_hinge_stat_mean.to_csv(self.root_out/'结果统计'/'柱铰_统计_mean.csv', encoding='ANSI', float_format='%.6f')
        col_hinge_stat_std.to_csv(self.root_out/'结果统计'/'柱铰_统计_std.csv', encoding='ANSI', float_format='%.6f')
        col_hinge_stat_16th.to_csv(self.root_out/'结果统计'/'柱铰_统计_16th.csv', encoding='ANSI', float_format='%.6f')
        col_hinge_stat_50th.to_csv(self.root_out/'结果统计'/'柱铰_统计_50th.csv', encoding='ANSI', float_format='%.6f')
        col_hinge_stat_84th.to_csv(self.root_out/'结果统计'/'柱铰_统计_84th.csv', encoding='ANSI', float_format='%.6f')
        panel_zone_stat_mean.to_csv(self.root_out/'结果统计'/'节点域_统计_mean.csv', encoding='ANSI', float_format='%.6f')
        panel_zone_stat_std.to_csv(self.root_out/'结果统计'/'节点域_统计_std.csv', encoding='ANSI', float_format='%.6f')
        panel_zone_stat_16th.to_csv(self.root_out/'结果统计'/'节点域_统计_16th.csv', encoding='ANSI', float_format='%.6f')
        panel_zone_stat_50th.to_csv(self.root_out/'结果统计'/'节点域_统计_50th.csv', encoding='ANSI', float_format='%.6f')
        panel_zone_stat_84th.to_csv(self.root_out/'结果统计'/'节点域_统计_84th.csv', encoding='ANSI', float_format='%.6f')
        # 写入origin
        logger.info('正在写入Origin文件...')
        all_data: dict[str, tuple[pd.DataFrame, pd.DataFrame, str]] = {
            # y_lname: [data, data_stat, x_lname, unit]
            'IDR': (IDR, IDR_stat, ''),
            'IDRroof': (IDRroof, IDRroof_stat, ''),
            'DCF': (DCF, DCF_stat, ''),
            'Shear': (Shear, Shear_stat, 'kN'),
            'CIDR': (CIDR, CIDR_stat, ''),
            'PFV': (PFV, PFV_stat, 'mm/s'),
            'PFA': (PFA, PFA_stat, 'g'),
            'RIDR': (RIDR, RIDR_stat, ''),
        }
        if not self.attached_opju:
            file_path = self.root_out / f'{self.root_out.stem}.opju'
        else:
            file_path = self.attached_opju
        with WriteOrigin(op, file_path, self.root_out.stem):
            # writer.delete_obj('Book1')  # 删除自动生成的workbook
            for y_lname, valus in all_data.items():
                data, data_stat, unit = valus
                wb = op.new_book('w', y_lname)
                ws: WSheet = wb[0]
                ws.name = y_lname
                ws.from_list(0, data.index, lname='Story', units='')  # X列
                ws.from_df(data, c1=1)  # Y列
                ws.set_labels([unit] * len(data.columns), 'U', offset=1)  # 各楼层Y列单位
                ws.set_labels(['Individual'] * len(data.columns), 'C', offset=1)  # 各楼层Y列注释
                ws.from_df(data_stat, c1=len(data.columns) + 1)  # 统计特征Y列
                ws.set_labels([unit] * 5, 'U', offset=len(data.columns) + 1)  # 统计特征Y列单位
                ws.set_labels(['Mean', 'STD', '16%', '50%', '84%'], 'C', offset=len(data.columns) + 1)  # 统计特征Y列注释
                ws.set_labels([y_lname] * (ws.cols - 1), 'L', offset=1)  # 所有Y列长名称


if __name__ == "__main__":
    
    time0 = time.time()
    model = DataProcessing(r'H:\RockingFrameWithRSRD\MRF4S_AS_RD', gm_suffix='.th')
    model.set_output_dir(r'H:\RockingFrameWithRSRD\MRF4S_AS_RD_out', cover=1)
    model.read_results('mode', 'IDR')
    model.read_results('CIDR', 'PFA', 'PFV', 'shear', 'panelZone', 'beamHinge', 'columnHinge', print_result=True)
    # l1 = pow(6100**2 + 4300**2, 0.5)  # 首层斜撑长度
    # l2 = pow(6100**2 + 4000**2, 0.5)  # 其他层斜撑长度
    # model.read_pushover(H=16300, plot_result=True)
    # model.read_th()  # 只有时程分析工况需要用
    time1 = time.time()
    print('耗时', time1 - time0)




"""
weight:
    4层框架 - 

注：
带th的是时程分析结果，带pushover的是pushover分析结果，其他是IDA分析结果
时程分析和pushover分析只进行一次处理
"""
