"""
多层钢框架、混凝土框架OpenSees模型分析类
作者：Wenchen Lie
更新：2024.03.10
更新：2024-04-07，可设置最大运行时间，可选择不追踪倒塌点
更新：2024-04-12，增加多进程并行计算
"""
import os
import sys
import shutil
import re
import json
import pickle
from pathlib import Path
from math import pi
from typing import Literal

import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
from loguru import logger
from PyQt5.QtCore import Qt
from PyQt5.QtWidgets import QApplication, QMessageBox
from SeismicUtils import Records

from .Win import MyWin
from .Spectrum import Spectrum


logger.remove()
logger.add(
    sink=sys.stdout,
    format="<green>{time:YYYY-MM-DD HH:mm:ss}</green> <red>|</red> <level>{level}</level> <red>|</red> <level>{message}</level>",
    level="DEBUG"
)


class MRF:
    # 注：
    # (1) 代码仅支持Windows系统
    # (2) 导入的地震动、反应谱单位均默认为g

    format_version = '2.1'
    cwd = Path().cwd()
    dir_gm = cwd / 'GMs'
    dir_model = cwd / 'models'
    dir_temp = cwd / 'temp'
    dir_log = cwd / 'log'
    dir_terminal = cwd / 'OS_terminal'
    dir_subroutines = cwd / 'subroutines'

    def __init__(self, model_name: str, N: int, script: Literal['tcl', 'py']='tcl', notes=''):
        """实例化分析模型

        Args:
            model_name (str): 模型名称，应与tcl模型的文件名一致  
            N (int): 结构层数  
            notes (str, optional): 模型描述，默认为''  
            script (Literal['tcl', 'py']): 脚本类型，tcl或py  
            logger (logger, optional): 在主函数中定义的日志对象
        """
        self.logger = logger
        logger.success('钢框架时程分析/Pushover分析/IDA工具')
        logger.success(f'opensees代码格式版本：{self.format_version}')
        self._init_check_path(self.cwd, self.dir_gm, self.dir_model, self.dir_temp, self.dir_log, self.dir_terminal, self.dir_subroutines)
        self.model_name = model_name  # 模型名
        if script not in ['tcl', 'py']:
            raise ValueError('参数`script`应为"tcl"或"py"')
        self.script = script
        model_file = self.dir_model / f'{model_name}.{script}'
        if not model_file.exists():
            logger.error(f'无法找到模型 ({model_file.as_posix()})')
            raise ValueError('【Error】无法找到模型！')
        with open(self.dir_model / (f'{model_name}.{script}'), 'r') as f:
            self.script_text = f.read()
        self.N = N  # 层数
        self.notes = notes  # 模型说明
        self.GM_N = 0
        self.GM_names = []
        self.GM_dts = []
        self.GM_NPTS = []
        self.GM_durations = []
        self.GM_SF = []
        self.GM_RSA, self.GM_RSV, self.GM_RSD = None, None, None
        self.scaled_GM_RSA, self.scaled_GM_RSV, self.scaled_GM_RSD = None, None, None
        self.scaling_finished = False  # 是否完成地震动缩放
        self.suffix = '.txt'
        self.Output_dir = self.cwd
        self.do_not_run = False  # 运行分析
        self.maxRoofDrift = 0.1  # Pushover分析的目标层间位移角
        self.parallel = 0
        self._init_set_QApp()
        self._check_version()
        self.logger.success(f'已定义模型：{self.model_name}')
    
    @staticmethod
    def _init_check_path(*paths: Path):
        for path in paths:
            if re.search('[！@#￥%……&*（）—【】：；“‘”’《》，。？、\u4e00-\u9fff]', path.as_posix()):
                raise ValueError(f'路径存在中文字符：{path.as_posix()}')


    def _init_set_QApp(self):
        app = QApplication.instance()
        if not app:
            QApplication.setHighDpiScaleFactorRoundingPolicy(Qt.HighDpiScaleFactorRoundingPolicy.PassThrough)
            QApplication.setAttribute(Qt.AA_EnableHighDpiScaling)
            QApplication.setAttribute(Qt.AA_UseHighDpiPixmaps)
            self.app = QApplication(sys.argv)
        else:
            self.app = app


    def _check_version(self):
        file = self.dir_model / (f'{self.model_name}.{self.script}')
        with open(file, 'r') as f:
            text = f.read()
        pattern = re.compile(r'\(Version ([0-9.]+)\)')
        res = re.findall(pattern, text)
        if len(res) == 0:
            self.logger.warning('无法找到opensees脚本文本格式版本号！')
            return
        v = res[0]
        if not v == self.format_version:
            self.logger.warning(f'opensees脚本文本格式版本号({v})与本程序兼容的版本({self.format_version})不对应，可能会产生未知问题！')


    def select_ground_motions(self, GMs: list[str], suffix: str='.txt'):
        """选择地震动文件

        Args:
            GMs (list[str]): 一个包含所有地震动文件名(不包括后缀)的列表  
            suffix (str, optional): 地震动文件后缀，默认为.txt

        Example:
            >>> select_ground_motions(GMs=['GM1', 'GM2'], suffix='.txt')
        """
        self.suffix = suffix
        self.GM_names = GMs
        with open(self.dir_gm / 'GM_info.json', 'r') as f:
            dt_dict = json.loads(f.read())
        for name in self.GM_names:
            self.GM_dts.append(dt_dict[name])
            th = np.loadtxt(self.dir_gm / f'{name}{suffix}')
            self.GM_NPTS.append(len(th))
            self.GM_durations.append(round((len(th) - 1) * dt_dict[name], 6))
        self.GM_N = len(self.GM_names)
        self.logger.success(f'已导入{self.GM_N}条地震动')


    @staticmethod
    def Sa(T: np.ndarray, S: np.ndarray, T0: float, withIdx=False) -> float:
        for i in range(len(T) - 1):
            if T[i] <= T0 <= T[i+1]:
                k = (S[i+1] - S[i]) / (T[i+1] - T[i])
                S0 = S[i] + k * (T0 - T[i])
                if withIdx:
                    return S0, i
                else:
                    return S0
        else:
            raise ValueError(f'无法找到周期点{T0}对应的加速度谱值！')


    @staticmethod
    def RMSE(a: np.ndarray, b: np.ndarray) -> float:
        # 均方根误差
        return np.sqrt(np.mean((a - b) ** 2))
    

    # 梯度下降法
    @staticmethod
    def gradient_descent(a, b, init_SF, learning_rate, num_iterations):
        f = init_SF
        for _ in range(num_iterations):
            error = a * f - b
            gradient = 2 * np.dot(error, a) / len(a)
            f -= learning_rate * gradient
        return f


    def scale_ground_motions(self,
            method: str,
            para: None | float | tuple | str,
            path_spec_code: str | None=None,
            SF_code: float=1.0,
            save_SF=False,
            plot=True,
            save_unscaled_spec=False,
            save_scaled_spec=False
        ):
        """缩放地震动，仅运行时程分析前需要调用，
        如果运行IDA或者Pushover，可以不调用。  

        Args:
            method (str): 地震动的缩放方法，为'a'-'g'：  
            * [a] 按Sa(T=0)匹配反应谱, pare=None  
            * [b] 按Sa(T=Ta)匹配反应谱, para=Ta  
            * [c] 按Sa(Ta) ~ Sa(Tb)匹配反应谱, para=(Ta, Tb)  
            * [d] 指定PGA, para=PGA  
            * [e] 不缩放  
            * [f] 指定相同缩放系数, para=SF  
            * [g] 按文件指定, para=path: str (如'temp/GM_SFs.txt')，文件包含一列n行个数据  
            * [h] 按Sa,avg(T1, T2)匹配反应谱，即T1~T2间的加速度谱值的几何平均数，para=(T1, T2)  
            * [i] 指定Sa(Ta), para=(Ta, Sa)  
            * [j] 指定Sa,avg(Ta~Tb), para=(Ta, Tb, Sa,avg)\n
            分别代表n条地震动的缩放系数  
            para: 地震动缩放所需参数，与`method`的取值有关  
            path_spec_code (str, optional): 目标谱的文件路径，文件应包含两列数据，为周期和加速度谱值，默认None  
            SF_code (float, optional): 读取目标谱时将目标谱乘以一个缩放系数，默认为1  
            save (bool, optional): 是否保存缩放后的缩放系数(将保存至temp文件夹，
            可以作为`method`取'g'时`para`参数对应的文件路径，默认为False  
            plot (bool, optional): 是否绘制缩放后地震动反应谱与目标谱的对比图，默认为True  
            save_unscaled_spec (bool, optional): 是否保存未缩放地震动反应谱，默认False  
            save_scaled_spec (bool, optional): 是否保存缩放后地震动反应谱，默认False
        """
        self.method = method
        self.th_para = para
        if path_spec_code is not None:
            data = np.loadtxt(path_spec_code)
            T = data[:, 0]
            Sa_code = data[:, 1] * SF_code
            Sv_code = Sa_code * T / (2 * pi)
            Sd_code = Sa_code * (T / (2 * pi)) ** 2
        else:
            T = np.arange(0, 6.01, 0.01)
            Sa_code = None
            Sv_code = None
            Sd_code = None
        self.T = T
        self.scaled_GM_RSA = np.zeros((self.GM_N, len(T)))
        self.scaled_GM_RSV = np.zeros((self.GM_N, len(T)))
        self.scaled_GM_RSD = np.zeros((self.GM_N, len(T)))
        if method == 'g':
            SF_path = para
            SFs = np.loadtxt(SF_path)
        self.GM_RSA = np.zeros((self.GM_N, len(T)))
        self.GM_RSV = np.zeros((self.GM_N, len(T)))
        self.GM_RSD = np.zeros((self.GM_N, len(T)))
        is_print = True
        for idx, gm_name in enumerate(self.GM_names):
            print(f'正在缩放地震动...({idx+1}/{self.GM_N})     \r', end='')
            th = np.loadtxt(self.dir_gm / f'{gm_name}{self.suffix}')
            RSA, RSV, RSD = Spectrum(ag=th, dt=self.GM_dts[idx], T=T)  # 计算地震动反应谱
            self.GM_RSA[idx] = RSA
            self.GM_RSV[idx] = RSV
            self.GM_RSD[idx] = RSD    
            if method == 'a':
                if path_spec_code is None:
                    raise ValueError('Argument `path_spec_code` should be given')
                T0 = 0
                SF = self.Sa(T, Sa_code, T0) / self.Sa(T, RSA, T0)
                self.GM_SF.append(SF)
            elif method == 'b':
                if path_spec_code is None:
                    raise ValueError('Argument `path_spec_code` should be given')
                T0 = para
                if is_print:
                    self.logger.info(f'Sa(T1) = {self.Sa(T, RSA, T0)}')
                    is_print = False
                SF = self.Sa(T, Sa_code, T0) / self.Sa(T, RSA, T0)
                self.GM_SF.append(SF)
            elif method == 'c':
                if path_spec_code is None:
                    raise ValueError('Argument `path_spec_code` should be given')
                T1, T2 = para
                idx1, idx2 = self.Sa(T, RSA, T1, True)[1], self.Sa(T, RSA, T2, True)[1]
                init_SF = 1.0  # 初始缩放系数
                learning_rate = 0.01  # 学习率
                num_iterations = 40000  # 迭代次数
                init_SF = np.mean(Sa_code[idx1: idx2]) / np.mean(RSA[idx1: idx2])
                SF = self.gradient_descent(RSA[idx1: idx2], Sa_code[idx1: idx2], init_SF, learning_rate, num_iterations)
            elif method == 'd':
                PGA = para
                SF = PGA / max(abs(th))
            elif method == 'e':
                SF = 1
            elif method == 'f':
                SF = para
            elif method == 'g':
                SF = SFs[idx] 
            elif method == 'h':
                if path_spec_code is None:
                    raise ValueError('Argument `path_spec_code` should be given')
                Sa_i_code = []
                Sa_i = []
                T1, T2 = para
                for i in range(len(T)):
                    Ti = T[i]
                    if T1 <= Ti <= T2:
                        Sa_i_code.append(Sa_code[i])
                        Sa_i.append(RSA[i])
                Sa_avg_code = self.geometric_mean(Sa_i_code)
                Sa_avg = self.geometric_mean(Sa_i)
                SF = Sa_avg_code / Sa_avg
                if is_print:
                    self.logger.info(f'Sa,avg = {Sa_avg_code}')
                    is_print = False
            elif method == 'i':
                Ta, Sa_target = para
                Sa_gm = self.Sa(T, RSA, Ta)
                SF = Sa_target / Sa_gm
            elif method == 'j':
                Ta, Tb, Sa_target = para
                Sa_gm_avg = self.geometric_mean(RSA[(Ta <= T) & (T <= Tb)])
                SF = Sa_target / Sa_gm_avg
            else:
                self.logger.error('`method`参数错误！')
                raise ValueError('`method`参数错误！')
            self.scaled_GM_RSA[idx] = RSA * SF
            self.scaled_GM_RSV[idx] = RSV * SF
            self.scaled_GM_RSD[idx] = RSD * SF
            self.GM_SF.append(SF)
            if save_SF:
                np.savetxt(self.dir_temp / 'GM_SFs.txt', self.GM_SF)  # 保存缩放系数
        if save_unscaled_spec:
            data_RSA = np.zeros((len(T), self.GM_N + 1))
            data_RSV = np.zeros((len(T), self.GM_N + 1))
            data_RSD = np.zeros((len(T), self.GM_N + 1))
            data_RSA[:, 0] = T
            data_RSV[:, 0] = T
            data_RSD[:, 0] = T
            data_RSA[:, 1:] = self.GM_RSA.T
            data_RSV[:, 1:] = self.GM_RSV.T
            data_RSD[:, 1:] = self.GM_RSD.T
            pct_A, pct_V, pct_D = np.zeros((len(T), 3)), np.zeros((len(T), 3)), np.zeros((len(T), 3))
            for i in range(len(T)):
                pct_A[i, 0] = np.percentile(data_RSA[i, 1:], 16)
                pct_A[i, 1] = np.percentile(data_RSA[i, 1:], 50)
                pct_A[i, 2] = np.percentile(data_RSA[i, 1:], 84)
                pct_V[i, 0] = np.percentile(data_RSV[i, 1:], 16)
                pct_V[i, 1] = np.percentile(data_RSV[i, 1:], 50)
                pct_V[i, 2] = np.percentile(data_RSV[i, 1:], 84)
                pct_D[i, 0] = np.percentile(data_RSD[i, 1:], 16)
                pct_D[i, 1] = np.percentile(data_RSD[i, 1:], 50)
                pct_D[i, 2] = np.percentile(data_RSD[i, 1:], 84)
            np.savetxt(self.dir_temp / 'Unscaled_RSA.txt', data_RSA, fmt='%.5f')
            np.savetxt(self.dir_temp / 'Unscaled_RSV.txt', data_RSV, fmt='%.5f')
            np.savetxt(self.dir_temp / 'Unscaled_RSD.txt', data_RSD, fmt='%.5f')
            np.savetxt(self.dir_temp / 'Unscaled_RSA_pct.txt', pct_A, fmt='%.5f')
            np.savetxt(self.dir_temp / 'Unscaled_RSV_pct.txt', pct_V, fmt='%.5f')
            np.savetxt(self.dir_temp / 'Unscaled_RSD_pct.txt', pct_D, fmt='%.5f')
            np.savetxt(self.dir_temp / 'Unscaled_RSA.txt', data_RSA, fmt='%.5f')
            np.savetxt(self.dir_temp / 'Unscaled_RSV.txt', data_RSV, fmt='%.5f')
            np.savetxt(self.dir_temp / 'Unscaled_RSD.txt', data_RSD, fmt='%.5f')
            np.savetxt(self.dir_temp / 'Unscaled_RSA_pct.txt', pct_A, fmt='%.5f')
            np.savetxt(self.dir_temp / 'Unscaled_RSV_pct.txt', pct_V, fmt='%.5f')
            np.savetxt(self.dir_temp / 'Unscaled_RSD_pct.txt', pct_D, fmt='%.5f')
            self.logger.info(f'已保存未缩放反应谱至temp文件夹')
        if save_scaled_spec:
            data_RSA = np.zeros((len(T), self.GM_N + 1))
            data_RSV = np.zeros((len(T), self.GM_N + 1))
            data_RSD = np.zeros((len(T), self.GM_N + 1))
            data_RSA[:, 0] = T
            data_RSV[:, 0] = T
            data_RSD[:, 0] = T
            data_RSA[:, 1:] = self.scaled_GM_RSA.T
            data_RSV[:, 1:] = self.scaled_GM_RSV.T
            data_RSD[:, 1:] = self.scaled_GM_RSD.T
            pct_A, pct_V, pct_D = np.zeros((len(T), 3)), np.zeros((len(T), 3)), np.zeros((len(T), 3))
            for i in range(len(T)):
                pct_A[i, 0] = np.percentile(data_RSA[i, 1:], 16)
                pct_A[i, 1] = np.percentile(data_RSA[i, 1:], 50)
                pct_A[i, 2] = np.percentile(data_RSA[i, 1:], 84)
                pct_V[i, 0] = np.percentile(data_RSV[i, 1:], 16)
                pct_V[i, 1] = np.percentile(data_RSV[i, 1:], 50)
                pct_V[i, 2] = np.percentile(data_RSV[i, 1:], 84)
                pct_D[i, 0] = np.percentile(data_RSD[i, 1:], 16)
                pct_D[i, 1] = np.percentile(data_RSD[i, 1:], 50)
                pct_D[i, 2] = np.percentile(data_RSD[i, 1:], 84)
            np.savetxt(self.dir_temp / 'Scaled_RSA.txt', data_RSA, fmt='%.5f')
            np.savetxt(self.dir_temp / 'Scaled_RSV.txt', data_RSV, fmt='%.5f')
            np.savetxt(self.dir_temp / 'Scaled_RSD.txt', data_RSD, fmt='%.5f')
            np.savetxt(self.dir_temp / 'Scaled_RSA_pct.txt', pct_A, fmt='%.5f')
            np.savetxt(self.dir_temp / 'Scaled_RSV_pct.txt', pct_V, fmt='%.5f')
            np.savetxt(self.dir_temp / 'Scaled_RSD_pct.txt', pct_D, fmt='%.5f')
            np.savetxt(self.dir_temp / 'Scaled_RSA.txt', data_RSA, fmt='%.5f')
            np.savetxt(self.dir_temp / 'Scaled_RSV.txt', data_RSV, fmt='%.5f')
            np.savetxt(self.dir_temp / 'Scaled_RSD.txt', data_RSD, fmt='%.5f')
            np.savetxt(self.dir_temp / 'Scaled_RSA_pct.txt', pct_A, fmt='%.5f')
            np.savetxt(self.dir_temp / 'Scaled_RSV_pct.txt', pct_V, fmt='%.5f')
            np.savetxt(self.dir_temp / 'Scaled_RSD_pct.txt', pct_D, fmt='%.5f')
            self.logger.info(f'已保存缩放反应谱至temp文件夹')
        plt.subplot(131)
        if method == 'a':
            plt.scatter(0, Sa_code[0], color='red', zorder=99999)
        elif method == 'b':
            plt.scatter(T0, self.Sa(T, Sa_code, T0), color='red', zorder=99999)
        elif method == 'c':
            plt.scatter(para, [self.Sa(T, Sa_code, para[0]), self.Sa(T, Sa_code, para[1])], color='red', zorder=99999)
        elif method == 'd':
            plt.scatter(0, PGA, color='red', zorder=99999)
        elif method == 'h':
            plt.scatter(para, [self.Sa(T, Sa_code, para[0]), self.Sa(T, Sa_code, para[1])], color='red', zorder=99999)
        elif method == 'i':
            plt.scatter(para[0], para[1], color='red', zorder=99999)
        for i in range(self.GM_N):
            plt.subplot(131)
            plt.plot(T, self.scaled_GM_RSA[i], color='grey')
            plt.subplot(132)
            plt.plot(T, self.scaled_GM_RSV[i], color='grey')   
            plt.subplot(133)
            plt.plot(T, self.scaled_GM_RSD[i], color='grey')    
        plt.subplot(131)
        if Sa_code is not None:
            plt.plot(T, Sa_code, label='Code', color='red')
            plt.legend()
        plt.xlabel('T [s]')
        plt.ylabel('RSA [g]')
        plt.subplot(132)
        if Sv_code is not None:
            plt.plot(T, Sv_code, label='Code', color='red')
            plt.legend()
        plt.xlabel('T [s]')
        plt.ylabel('RSV [mm/s]')
        plt.subplot(133)
        if Sd_code is not None:
            plt.plot(T, Sd_code, label='Code', color='red')
            plt.legend()
        plt.xlabel('T [s]')
        plt.ylabel('RSD [mm]')
        if plot:
            plt.show()
        else:
            plt.close()
        self.scaling_finished = True

    # TODO: 后处理暂不支持从pkl读取地震动
    def records_from_pickle(self,
            pkl_file: Path | str,
            scale: Literal['scaled', 'unscaled', 'normalised']='scaled'
        ) -> None:
        """从pickle导入并缩放地震动，其中pickle文件从GroungMotons项目获得

        Args:
            pkl_file (Path | str): pickle文件路径
            scale (Literal['scaled', 'unscaled', 'normalised'], optional): 缩放方法: 缩放, 不缩放, 归一化，默认'scaled'
        """
        if not Path(pkl_file).exists():
            raise FileNotFoundError(f'无法找到文件：{str(Path(pkl_file).absolute())}')
        with open(pkl_file, 'rb') as f:
            records: Records = pickle.load(f)
        if scale == 'scaled':
            results = records.get_scaled_records()
        elif scale == 'unscaled':
            results = records.get_unscaled_records()
        elif scale == 'normalised':
            results = records.get_normalised_records()
        else:
            raise ValueError(f'参数`scale`错误！')
        self.GM_N = records.N_gm
        self.GM_names = []
        for i, (th, dt) in enumerate(results):
            self.GM_names.append(f'pkl_No_{i + 1}')
            self.GM_dts.append(dt)
            self.GM_NPTS.append(len(th))
            self.GM_durations.append(round((len(th) - 1) * dt, 6))
        self.logger.success(f'已从{Path(pkl_file).name}导入{self.GM_N}条地震动')
        # TODO: 地震动缩放

    def _check_Output_dir(self):
        # 判断输出文件夹是否存在
        if os.path.exists(self.Output_dir):
            if self.folder_exists == 'ask':
                res1 = QMessageBox.question(None, '警告', f'{self.Output_dir}已存在，是否删除？')
                if res1 == QMessageBox.Yes:
                    shutil.rmtree(self.Output_dir)
                    os.makedirs(self.Output_dir)
                    return True
                else:
                    res2 = QMessageBox.question(None, '警告', f'是否覆盖数据？')
                    if res2 == QMessageBox.Yes:
                        return True
                    else:
                        self.logger.warning('已退出分析')
                        return False
            elif self.folder_exists == 'overwrite':
                return True
            elif self.folder_exists == 'delete':
                shutil.rmtree(self.Output_dir)
                os.makedirs(self.Output_dir)
                return True
        else:
            os.makedirs(self.Output_dir)
            return True


    def set_running_parameters(
            self, Output_dir: str | Path=None, OS_terminal: str='OpenSees351',
            fv_duration=0.0, display=True, mpco=False, log_name='日志',
            maxRunTime: float=600, auto_quit: bool=False,
            folder_exists: Literal['ask', 'overwrite', 'delete']='ask'):
        """设置运行参数

        Args:
            Output_dir (str, optional): 结果文件的输出路径，为None时则为当前工作路径  
            OS_terminal (str, optional): OpenSees终端的版本（不带后缀的文件名，默认为OpenSees351），  
            可执行终端文件都放在OS_terminal文件夹  
            fv_duration (float, optional): 时程分析时的自由振动时长，默认为0，  
            运行pushover时可不传参或随便填一个数  
            display (bool): 是否显示运行时结构的实时变形图(IDA计算或采用openseespy时不支持)  
            mpco (bool): 是否创建mpco文件，用于被STKO读取后处理(采用openseespy时不支持)  
            log_name (str): 日志文件名  
            maxRunTime (float): 最大允许运行时间(s)，默认600s  
            auto_quit (bool): 计算完成时是否自动关闭监控窗口，默认False  
            folder_exists (bool): 如果输出文件夹存在，如何处理。ask-询问，overwrite-覆盖，delete-删除
        """
        if self.script == 'py' and display:
            logger.warning('使用openseespy时暂时无法显示实时变形动画')
            display = False
        self.display = display
        self.mpco = mpco
        self.log_name = log_name
        self.maxRunTime = maxRunTime
        self.auto_quit = auto_quit
        self.folder_exists = folder_exists
        if Output_dir:
            Output_dir = Path(Output_dir).absolute()
            self.Output_dir = Output_dir
        if not self._check_Output_dir():
            self.do_not_run = True
            return
        with open(f'{self.Output_dir}/notes.dat', 'w') as f:
            f.write(self.notes)
        with open(f'{self.Output_dir}/N.dat', 'w') as f:
            f.write(str(self.N))
        with open(f'{self.Output_dir}/ground_motions.dat', 'w') as f:
            text = '\n'.join(self.GM_names)
            f.write(text)
        if mpco:
            OS_terminal = 'OpenSees340_mpco'
            logger.warning('当输出mpco时将默认使用OpenSees340_mpco.exe求解器')
        self.OS_path = self.dir_terminal / f'{OS_terminal}.exe'
        self.fv_duration = fv_duration
        

    def run_time_history(self, print_result=False, collapse_limit: float=0.1, parallel: int=0):
        """运行时程分析

        Args:
            print_result (bool, optional): 是否打印OpenSees输出的信息，默认为False
            collapse_limit (float, optional): 倒塌判定极限位移角，默认0.1
            parallel (int, optional): 多进程并行计算，默认为0，代表不开启并行，为其他数时则代表最大进程数
        """
        if self.do_not_run:
            return
        if not self.scaling_finished:
            self.logger.error('未进行地震动缩放！')
            raise ValueError('未进行地震动缩放！')
        if not isinstance(parallel, int) or parallel < 0:
            self.logger.error('参数parallel格式错误，必须为大于等于0的整数')
            raise ValueError('parallel格式错误')
        self.parallel = parallel
        self.collapse_limit = collapse_limit
        if self.display and parallel > 0:
            self.logger.warning('采用多进程并行计算时，暂不支持显示实时动画')
            self.display = False
        self.logger.info('开始进行时程分析')
        with open(f'{self.Output_dir}/running_case.dat', 'w') as f:
            f.write('TH')
        self._exec_win(running_case='TH', IDA_para=None, print_result=print_result)


    def run_IDA(
            self, T0: float, Sa0: float, Sa_incr: float, tol: float, collapse_limit: float=0.1,
            max_ana=30, test=False, intensity_measure: Literal[1, 2]=1, T_range: tuple=None,
             print_result=False, trace_collapse: bool=True, parallel: int=0):
        """IDA分析

        Args:
            T0 (float): 一阶周期  
            Sa0 (float): 初始强度值  
            Sa_incr (float): 强度增量  
            tol (float): 倒塌点收敛容差  
            collapse_limit (float): 倒塌判定极限位移角，默认0.1  
            max_ana (int, optional): 每个地震动最大分析次数，默认30  
            test (bool, optional): 程序调试用  
            intensity_measure (int, optional): 地震动强度指标  
            * 1: Sa(T0), T0为一阶周期  
            * 2: Sa,avg, 给定周期范围内的简单几何平方根  \n
            T_range (tuple, optional): 周期范围，默认None，当`intensity_measure`为2时生效  
            print_result (bool, optional): 是否打印opensees终端输出的结果，默认不打印  
            trace_collapse (bool, optional): 是否追踪倒塌，默认True（若False则不动态调整地震动强度以搜寻倒塌点）  
            parallel (int, optional): 多进程并行计算，默认为0，代表不开启并行，为其他数时则代表最大进程数
        """
        if self.do_not_run:
            return
        self.logger.info('开始进行IDA')
        self.trace_collapse = trace_collapse
        self.collapse_limit = collapse_limit
        if not isinstance(parallel, int) or parallel < 0:
            self.logger.error('参数parallel格式错误，必须为大于等于0的整数')
            raise ValueError('parallel格式错误')
        self.parallel = parallel
        if self.display and parallel > 0:
            self.logger.warning('采用多进程并行计算时，暂不支持显示实时动画')
            self.display = False
        # 计算无缩放反应谱
        T = np.arange(0, 6.01, 0.01)
        self.T = T
        self.GM_RSA, self.GM_RSV, self.GM_RSD = np.zeros((self.GM_N, len(T))), np.zeros((self.GM_N, len(T))), np.zeros((self.GM_N, len(T)))
        for idx in range(self.GM_N):
            print(f'正在计算地震动反应谱...({idx+1}/{self.GM_N})     \r', end='')
            th = np.loadtxt(self.dir_gm / f'{self.GM_names[idx]}{self.suffix}')
            RSA, RSV, RSD = Spectrum(th, self.GM_dts[idx], T)
            self.GM_RSA[idx] = RSA
            self.GM_RSV[idx] = RSV
            self.GM_RSD[idx] = RSD
        IDA_para = (T0, self.GM_RSA, Sa0, Sa_incr, tol, max_ana, test, intensity_measure, T_range)
        with open(f'{self.Output_dir}/running_case.dat', 'w') as f:
            f.write('IDA')
        self._exec_win(running_case='IDA', IDA_para=IDA_para, print_result=print_result)


    def run_pushover(self, maxRoofDrift: float=0.1, print_result=False):
        """运行pushover分析

        Args:
            maxRoofDrift (float): 目标最大层间位移角
            print_result (bool, optional): 是否打印OpenSees输出的内容，默认为False
        """
        if self.do_not_run:
            return
        self.logger.info('开始进行Pushover分析')
        self.maxRoofDrift = maxRoofDrift
        with open(f'{self.Output_dir}/ground_motions.dat', 'w') as f:
            f.write('pushover')
        IDA_para = None
        with open(f'{self.Output_dir}/running_case.dat', 'w') as f:
            f.write('PO')
        self._exec_win(running_case='PO', IDA_para=IDA_para, print_result=print_result)


    def run_cyclic_pushover(self, RDR_path: list[float], print_result=False, plot_path: bool=True):
        """运行cyclic pushover分析

        Args:
            RDR_path (list[float]): 屋顶位移角的加载路径
            print_result (bool, optional): 是否打印OpenSees输出的内容，默认为False
            plot_path (bool, optional): 是否绘制加载路径，默认True
        """
        if self.do_not_run:
            return
        self.logger.info('开始进行Cyclic pushover分析')
        if plot_path:
            plt.plot(RDR_path, '-o')
            plt.ylabel('Roof drift ratio')
            plt.show()
        self.RDR_path = RDR_path
        with open(f'{self.Output_dir}/ground_motions.dat', 'w') as f:
            f.write('Cyclic pushover')
        IDA_para = None
        with open(f'{self.Output_dir}/running_case.dat', 'w') as f:
            f.write('CP')
        self._exec_win(running_case='CP', IDA_para=IDA_para, print_result=print_result)


    def _exec_win(self, running_case: str, IDA_para: tuple, print_result: bool):
        if not self.dir_temp.exists():
            os.makedirs(self.dir_temp)
        if not self.dir_log.exists():
            os.makedirs(self.dir_log)
        myshow = MyWin(self, running_case, IDA_para=IDA_para, print_result=print_result)
        myshow.show()
        self.app.exec_()


    @staticmethod
    def geometric_mean(data):  # 计算几何平均数
        total = 1
        n = len(data)
        for i in data:
            total *= pow(i, 1 / n)
        return total


    @staticmethod
    def _get_y(x: list, y: list, x0: float) -> float:
        """获得竖线x=x0与给定曲线的交点纵坐标

        Args:
            x (list): 输入曲线的横坐标序列
            y (list): 输入曲线的纵坐标序列
            x0 (float): 竖直线x = x0

        Returns:
            float: 曲线与竖线交点纵坐标
        """
        # 获得x=x0与曲线的交点
        if x0 < min(x):
            raise ValueError(f'【Error】x0 < min(x) ({x0} < {min(x)})')
        if x0 > max(x):
            raise ValueError(f'【Error】x0 > max(x) ({x0} > {max(x)})')
        for i in range(len(x) - 1):
            if x[i] == x0:
                y0 = y[i]
                return y0
            elif x[i] < x0 <= x[i + 1]:
                k = (y[i + 1] - y[i]) / (x[i + 1] - x[i])
                y0 = k * (x0 - x[i]) + y[i]
                return y0
        else:
            raise ValueError('【Error】未找到交点-2')



    