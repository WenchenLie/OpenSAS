import numpy as np
import os
import sys
import matplotlib.pyplot as plt
from matplotlib.axes import Axes
from scipy.stats import norm
import openpyxl as px
from pathlib import Path
from loguru import logger
from wsection import WSection
import func

"""
最后更新：2024-04-07，优化画图代码，增加保存结果图像文件
"""

logger.remove()
logger.add(
    sink=sys.stdout,
    format="<green>{time:YYYY-MM-DD HH:mm:ss}</green> <red>|</red> <level>{level}</level> <red>|</red> <level>{message}</level>",
    level="DEBUG"
)


def get_x(x: list, y: list, y0: float) -> float:
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
        elif y[i] < y0 <= y[i + 1]:
            k = (y[i + 1] - y[i]) / (x[i + 1] - x[i])
            x0 = x[i] + (y0 - y[i]) / k
            return x0
    else:
        raise ValueError('【Error】未找到交点-1')

def get_y(x: list, y: list, x0: float) -> float:
    """获得竖线x=x0与给定曲线的交点纵坐标

    Args:
        x (list): 输入曲线的横坐标序列\n
        y (list): 输入曲线的纵坐标序列\n
        x0 (float): 竖直线x = x0\n

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
    
def get_percentile_line(all_x: list[list], all_y: list[list], p: float, n: int, x0: float, x1: float) -> tuple[np.ndarray, np.ndarray]:
    """计算IDA曲线簇的百分位线

    Args:
        all_x (list[list]): 所有独立IDA的横坐标\n
        all_y (list[list]): 所有独立IDA的纵坐标\n
        p (float): 百分位值\n
        n (int): 输出的百分为线横坐标的点数量\n
        x0 (float): 百分为线的横坐标起始范围\n
        x1 (float): 百分为线的横坐标结束范围\n

    Returns:
        tuple[np.ndarray, np.ndarray]: 百分位线的横坐标、纵坐标
    """
    # 计算百分位线
    x = np.linspace(x0, x1, n)  # 百分位线横坐标
    y = []  # 百分位线纵坐标
    for i, xi in enumerate(x):
        # xi: int, yi: list
        yi = [get_y(all_x[i], all_y[i], xi) for i in range(len(all_x))]
        y_percentile = np.percentile(yi, p)
        y.append(y_percentile)
    y = np.array(y)
    return x, y




class FragilityAnalysis():
    EDP_file = {1: '层间位移角', 2: '残余层间位移角', 3: '层加速度(g)',
               4: '屋顶加速度时程(绝对)(g)', 5: '屋顶速度时程(绝对)'}
    EDP_name = {1: '层间位移角', 2: '残余层间位移角', 3: '层加速度包络',
               4: '屋顶加速度', 5: '屋顶速度'}
    span = 3

    def __init__(self, root: str | Path, EDP_type: int):
        """地震易损性、倒塌易损性分析

        Args:
            root (str | Path): 待读取数据的文件夹的路径\n
            EDP_type (int): 工程需求参数类型
            * 1 - 最大层间位移角
            * 2 - 残余层间位移角
            * 3 - 楼层加速度包络
            * 4 - 屋顶最大加速度
            * 5 - 楼层速度包络
        """
        self.Calc_collapse = False  # 是否有进行倒塌易损性计算
        self.Calc_p = False  # 是否有进行EDP超越概率计算
        self.root = Path(root)
        self.EDP_type = EDP_type
        self.EDP_file = self.EDP_file[EDP_type] + '.out'
        self._check_file()
        self._read_file()
        # ResultFolder = model + '_new'
        # self.init_ReadFile(ResultFolder, EDP_type)

    def _check_file(self):
        # 数据初步检查
        list_ = ['ground_motions', 'N', 'running_case']
        for file in list_:
            if not Path.exists(self.root/f'{file}.dat'):
                raise ValueError('【Error】未找到{}'.format(self.root/f'{file}.dat'))
        self.GM_names = np.loadtxt(self.root/'ground_motions.dat', dtype=str, ndmin=1).tolist()  # 地震动名
        self.GM_N = len(self.GM_names)
        self.N = int(np.loadtxt(self.root/'N.dat'))  # 楼层数
        with open(self.root/'notes.dat', 'r') as f:
            self.notes = f.read()
        self.running_case = str(np.loadtxt(self.root / 'running_case.dat', dtype=str))
        if self.running_case != 'IDA':
            raise ValueError('【Error】本程序仅支持处理IDA结果数据')
        logger.success('通过数据文件检查')

    def _read_file(self):
        """目的为获得`self.data`
        `self.data` : {GMname: [[Sa, ...], [EDP, ...], [collapsed_state, ...]]}
        * Sa: T1对应的加速度谱值Sa(T1)
        * EDP: 工程需求参数值，如最大层间位移角
        * collapsed_state: 倒塌状态，0为不倒塌，1为倒塌
        """
        # 读取数据
        self.data = {}
        for idx_gm in range(self.GM_N):
            # 遍历地震动
            gm_name = self.GM_names[idx_gm]
            num =  1
            list_Sa = []
            list_EDP = []
            list_collapsed_state = []
            while True:
                # 遍历每个动力增量
                folder = self.root / f'{gm_name}_{num}'
                if not Path.exists(folder):
                    break
                Sa = np.loadtxt(folder/'Sa.out')
                Sa = round(float(Sa), 6)
                EDP = max(abs(np.loadtxt(folder/self.EDP_file)))
                collapsed_state = int(np.loadtxt(folder/'倒塌判断.out'))
                list_Sa.append(Sa)
                list_EDP.append(EDP)
                list_collapsed_state.append(collapsed_state)
                num += 1
            self.data[gm_name] = [list_Sa, list_EDP, list_collapsed_state]
        # 每条地震波按Sa大小排序
        for key, value in self.data.items():
            temp = zip(self.data[key][0], self.data[key][1], self.data[key][2])
            sorted_temp = sorted(temp,key=lambda x: x[0])
            result = zip(*sorted_temp)
            value[0], value[1], value[2] = np.array([list(i) for i in result])
        logger.success('已读取数据')


    def calc_IDA(self, DM_limit: float=None, slope_limit: float=None):
        """计算IDA曲线簇\n
        注：仅DM_limit为界限计算IDA曲线，如果有的点的DM值超过DM_limit，
        则取为该点与上一个点之间的直线与竖线DM=DM_limit的交点，并忽略后续的所有点
        * `self.IDA_x`, `self.IDA_y`: 所有独立IDA曲线(list[np.array])(在DM_limit范围内)
        * `self.IM`, `self.DM`: 所有IDA曲线的散点坐标，用于拟合概率需求模型(在DM_limit范围内)
        * `self.pct_x`: 百分为线的横坐标
        * `self.pct_15`, `self.pct_50`, `self.pct_84`: 百分为线的纵坐标

        Args:
            DM_limit (float, optional): 如果DM值大于给定值，则不统计，
            若不指定，则默认不统计倒塌点
            (当EDP采用层间位移角时，可设为0.1或0.15)\n
            slope_limit (float, optinal): 如果IDA曲线某点的斜率与初始斜率之比小于`slope_limit`，
            则删除该点及之后的数据
        """
        # IDA曲线
        self.IM, self.DM = np.array([]), np.array([])  # IDA曲线的散点坐标
        self.IDA_x, self.IDA_y = [], []  # IDA曲线(多条)
        for gm_name, value in self.data.items():
            # value: [[Sa, ...], [EDP, ...], [collaplsed_state, ...]]
            IDA_xi, IDA_yi = value[1], value[0]  # IDA曲线(单条)
            IDA_xi = np.insert(IDA_xi, 0, 0)
            IDA_yi = np.insert(IDA_yi, 0, 0)
            if DM_limit:
                for idx in range(1, len(IDA_xi)):
                    if IDA_xi[idx] == DM_limit:
                        y0 = IDA_yi[idx]
                        skip = 0
                        break
                    elif IDA_xi[idx - 1] < DM_limit < IDA_xi[idx]:
                        # 如果IDA曲线的横坐标范围超出DM_limit，则取为DM_limit
                        y0 = get_y([IDA_xi[idx - 1], IDA_xi[idx]],
                                   [IDA_yi[idx - 1], IDA_yi[idx]],
                                   DM_limit)  # 交点的纵坐标
                        skip = 0
                        break
                else:
                    skip = 1
                    logger.warning(f'DM_limit的值大于IDA曲线的最大横坐标范围')
                if skip == 0:
                    IDA_xi = IDA_xi[:idx + 1]
                    IDA_yi = IDA_yi[:idx + 1]
                    IDA_xi[idx] = DM_limit
                    IDA_yi[idx] = y0
            self.IDA_x.append(IDA_xi)
            self.IDA_y.append(IDA_yi)
        # 删除IDA曲线斜率小于给定值的后面的数据
        if slope_limit:
            for idx_gm in range(self.GM_N):
                IDA_xi = self.IDA_x[idx_gm]
                IDA_yi = self.IDA_y[idx_gm]
                slope0 = IDA_yi[1] / IDA_xi[1]  # 初始斜率
                for i in range(2, len(IDA_xi)):
                    x, y = IDA_xi[i], IDA_yi[i]
                    xim1, yim1 = IDA_xi[i-1], IDA_yi[i-1]
                    slope = (y - yim1) / (x - xim1)
                    if slope <= slope_limit:
                        self.IDA_x[idx_gm] = self.IDA_x[idx_gm][:i]
                        self.IDA_y[idx_gm] = self.IDA_y[idx_gm][:i]
                        break
        # 计算DM-IM散点
        for _, (x, y) in enumerate(zip(self.IDA_x, self.IDA_y)):
            self.IM = np.append(self.IM, y[1: -1])
            self.DM = np.append(self.DM, x[1: -1])
        # 计算百分位线
        x0 = 0
        if DM_limit:
            x1 = DM_limit
            if x1 > min([max(i) for i in self.IDA_x]):
                # 如果给定的DM_limit值比至少一条IDA曲线的最大横坐标范围大
                # 则取为该条IDA曲线的最大横坐标范围，以用于计算分位线
                x1 = min([max(i) for i in self.IDA_x])
        else:
            max_IDAs = [max(list_) for list_ in self.IDA_x]
            max_IDA = min(max_IDAs)
            x1 = max_IDA
        self.pct_x, self.pct_16 = get_percentile_line(self.IDA_x, self.IDA_y, p=16, n=300, x0=x0, x1=x1)
        _, self.pct_50 = get_percentile_line(self.IDA_x, self.IDA_y, p=50, n=300, x0=x0, x1=x1)
        _, self.pct_84 = get_percentile_line(self.IDA_x, self.IDA_y, p=84, n=300, x0=x0, x1=x1)
        self.IDA_range = (x0, max([max(i) for i in self.IDA_x]) * 1.05)  # 绘图范围
        logger.success('已计算IDA曲线')


    def frag_curve(self, Damage_State: list, label: list, betaDC=0.4):
        """对概率需求模型进行拟合

        Args:
            Damage_State (list): 不同损伤状态对应的EDP\n
            label (list): 不同损伤状态对应的描述\n
            IM1 (float): DM-IM曲线的横坐标范围起始值\n
            IM2 (float): DM-IM曲线的横坐标范围终止值\n
            betaDC (float, optional): sqrt(beta_D^2 + beta_C^2)的值(默认0.4)
        """
        # 概率需求模型，易损性曲线
        self.label = label  # 损伤状态符号
        IM1, IM2 = min(self.IM), max(self.IM)
        self.IM_fit = np.linspace(IM1, IM2, 1001)
        # ln(EDP) = A + B * ln(IM)
        # EDP = a * IM**b
        x, y = np.log(self.IM), np.log(self.DM)
        n = len(x)
        self.B = (n * sum(x * y) - sum(x) * sum(y)) / (n * sum(x**2) - sum(x)**2)
        self.A = (sum(y) - self.B * sum(x)) / n
        # self.B, self.A = np.polyfit(x, y, 1)
        y_pre = self.A + self.B * x
        SSR = np.sum((y - y_pre) ** 2)
        SST = np.sum((y - np.mean(y)) ** 2)
        self.R2 = 1 - (SSR / SST)
        self.a, self.b = np.exp(self.A), self.B
        self.x_frag = np.linspace(0.001, IM2 * 1.2, 1000)  # 易损性曲线x轴
        self.y_frag = []
        for i, DS in enumerate(Damage_State):
            self.y_frag.append(norm.cdf((self.A + self.B * np.log(self.x_frag) - np.log(DS)) / betaDC, 0, 1))  # 易损性曲线y轴
        # EDP和IM的对数关系
        self.DM_fit = np.exp(self.A + self.B * np.log(self.IM_fit))
        logger.success('已完成概率需求模型的拟合')


    def frag_collapse(self, IM_MCE: list):
        """计算倒塌易损性曲线
        * `self.collapsed_Sa`: 实际的倒塌点对应的Sa (list)
        * `self.x_clps_frag_real`, `self.y_clps_frag_real`: 实际的倒塌概率散点 (list)
        * `self.x_clps_frag_fit`, `self.y_clps_frag_fit`: 倒塌易损性拟合曲线 (np.ndarray)

        Args:
            IM_MCE (list): MCE地震下结构一阶周期对应的规范谱值Sa(T1)
        """
        # 计算倒塌点（倒塌点对应的Sa值）
        self.Calc_collapse = True  # 进行倒塌易损性计算
        self.collapsed_Sa = []  # 倒塌点(Sa)
        for gm_name, val in self.data.items():
            for i, clps_state in enumerate(val[2]):
                if clps_state == 1:
                    self.collapsed_Sa.append(val[0][i])
                    break
        self.clps_point_mean, self.clps_point_std, self.clps_point_50 =\
            np.mean(self.collapsed_Sa), np.std(self.collapsed_Sa), np.percentile(self.collapsed_Sa, 50)  # 倒塌点的均值、标准差、中位值
        # 计算实际倒塌超越概率点
        self.x_clps_frag_real = self.collapsed_Sa  # 实际的倒塌概率点(Sa, P)
        self.x_clps_frag_real = np.sort(self.x_clps_frag_real)
        self.y_clps_frag_real = np.array([i/self.GM_N for i in range(1, self.GM_N+1)])
        # 拟合倒塌易损性曲线
        ln_theta = 1 / len(self.x_clps_frag_real) * sum(np.log(self.x_clps_frag_real))
        theta = np.exp(ln_theta)
        beta = np.sqrt(1 / len(self.x_clps_frag_real) * sum((np.log(self.x_clps_frag_real / theta))**2))
        IM1, IM2 = 0.001, max(self.collapsed_Sa) * 1.2
        self.x_clps_frag_fit = np.linspace(IM1, IM2, 1001)  # 倒塌易损性曲线x
        self.y_clps_frag_fit = norm.cdf(np.log(self.x_clps_frag_fit / theta) / beta, 0, 1)  # 倒塌易损性曲线y
        # 倒塌裕度比（Collapse Margin Ratio，CMR）
        if IM_MCE:
            for i, IM in enumerate(IM_MCE):
                self.CMR = get_x(self.x_clps_frag_fit, self.y_clps_frag_fit, 0.5) / IM
        logger.success('已计算倒塌易损性曲线')


    def exceedance_probability(self, EDP_val: float):
        """计算任意EDP的超越概率
        * `self.EDP_Sa`: 实际的倒塌点对应的Sa (list)
        * `self.x_EDP_frag_real`, `self.y_EDP_frag_real`: 实际的倒塌概率散点 (list)
        * `self.x_EDP_frag_fit`, `self.y_EDP_frag_fit`: 倒塌易损性拟合曲线 (np.ndarray)

        Args:
            EDP_val (float): 给定一个EDP值(EDP_val)，求其超越概率
        """
        self.Calc_p = True  # 进行超越概率计算
        self.EDP_Sa = []  # 超越点(Sa)
        self.EDP_val = EDP_val
        for gm_name, val in self.data.items():
            for i, EDP in enumerate(val[1]):
                if EDP >= EDP_val:
                    self.EDP_Sa.append(val[0][i])
                    break
        self.EDP_point_mean, self.EDP_point_std, self.EDP_point_50 =\
            np.mean(self.EDP_Sa), np.std(self.EDP_Sa), np.percentile(self.EDP_Sa, 50)  # 超越点的均值、标准差、中位值
        # 计算实际超越概率点
        self.x_EDP_frag_real = self.EDP_Sa  # 实际的倒塌概率点(Sa, P)
        self.x_EDP_frag_real = np.sort(self.x_EDP_frag_real)
        self.y_EDP_frag_real = np.array([i/self.GM_N for i in range(1, self.GM_N+1)])
        # 拟合超越概率易损性曲线
        ln_theta = 1 / len(self.x_EDP_frag_real) * sum(np.log(self.x_EDP_frag_real))
        theta = np.exp(ln_theta)
        beta = np.sqrt(1 / len(self.x_EDP_frag_real) * sum((np.log(self.x_EDP_frag_real / theta))**2))
        IM1, IM2 = 0.001, max(self.EDP_Sa) * 1.2  # 计算、绘图范围
        self.x_EDP_frag_fit = np.linspace(IM1, IM2, 1001)  # 倒塌易损性曲线x
        self.y_EDP_frag_fit = norm.cdf(np.log(self.x_EDP_frag_fit / theta) / beta, 0, 1)  # 倒塌易损性曲线y
        logger.success('已计算EDP超越概率曲线')


    @staticmethod
    def fit_frag_curve(x_points: np.ndarray, y_points: np.ndarray, x_range: tuple=None, is_plot=False):
        ln_theta = 1 / len(x_points) * sum(np.log(x_points))
        theta = np.exp(ln_theta)
        beta = np.sqrt(1 / len(x_points) * sum((np.log(x_points / theta))**2))
        if x_range:
            x1, x2 = x_range
        else:
            x1, x2 = 0.001, max(x_points) * 1.2  # 计算、绘图范围
        x_fit = np.linspace(x1, x2, 1001)  # 倒塌易损性曲线x
        y_fit = norm.cdf(np.log(x_fit / theta) / beta, 0, 1)  # 倒塌易损性曲线y
        if is_plot:
            plt.plot(x_points, y_points, 'o')
            plt.plot(x_fit, y_fit)
            plt.show()
        return x_fit, y_fit


    def beam_damage(self, EDP_miu: list=None, EDP_theta: list=None, L_beam=5450):
        if not any([EDP_miu, EDP_theta]):
            raise ValueError('【Error】必须至少指定EDP_miu和EDP_theta的其中一个')
        data = {}
        for idx_gm in range(self.GM_N):
            # 遍历地震动
            gm_name = self.GM_names[idx_gm]
            num =  1
            list_Sa = []
            list_EDP = []
            list_collapsed_state = []
            while True:
                # 遍历每个动力增量
                folder = self.root / f'{gm_name}_{num}'
                if not Path.exists(folder):
                    break
                Sa = np.loadtxt(folder/'Sa.out')
                Sa = round(float(Sa), 6)
                EDP = np.loadtxt(folder/'梁铰变形.out')
                collapsed_state = int(np.loadtxt(folder/'倒塌判断.out'))
                if collapsed_state == 1:
                    num += 1
                    continue  # 不统计结构倒塌状态的数据
                list_Sa.append(Sa)
                list_EDP.append(EDP)
                list_collapsed_state.append(collapsed_state)
                num += 1
            data[gm_name] = [list_Sa, list_EDP, list_collapsed_state]
        # 每条地震波按Sa大小排序
        for key, value in data.items():
            temp = zip(data[key][0], data[key][1], data[key][2])
            sorted_temp = sorted(temp, key=lambda x: x[0])
            result = zip(*sorted_temp)
            value[0], value[1], value[2] = [list(i) for i in result]
        # 计算梁铰易损性
        p = 1
        P_l, P_r = np.zeros((self.N, 2 * self.span)), np.zeros((self.N, 2 * self.span))
        for floor in range(self.N):
            for span in range(self.span):
                section = func.get_section(4, 'beam', floor=floor+2, span=span+1)
                IDA_miux_l, IDA_miux_r, IDA_x_l, IDA_x_r, IDA_y = [], [], [], [], []  # IDA曲线簇
                for gm_name, val in data.items():
                    Sa = val[0]
                    theta_l = [matrix[floor, 2 * span] for matrix in val[1]]
                    theta_r = [matrix[floor, 2 * span + 1] for matrix in val[1]]
                    miu_l = func.get_ductility('beam', section, theta_l, floor, L_beam=L_beam)
                    miu_r = func.get_ductility('beam', section, theta_r, floor, L_beam=L_beam)
                    IDA_miux_l.append(miu_l)
                    IDA_miux_r.append(miu_r)
                    IDA_x_l.append(theta_l)
                    IDA_x_r.append(theta_r)
                    IDA_y.append(Sa)
                if p == 1:
                    for i in range(len(IDA_y)):
                        plt.plot(IDA_x_l[i], IDA_y[i], '-o')
                    plt.show()
                    p = 0

    def PlotCurves(self, plot_IDA_idx=None):
        # 画图
        self.fig, axes = plt.subplots(nrows=2, ncols=3, figsize=(18, 10))
        # 1 IDA曲线
        ax: Axes = axes[0, 0]
        for i, (x, y) in enumerate(zip(self.IDA_x, self.IDA_y)):
            if plot_IDA_idx == i:
                ax.plot(x, y, '-o', color='blue', markersize=6, label=f'idx={i}', zorder=9999)
            else:
                ax.plot(x, y, '-o', color='grey', markersize=4)
        ax.plot(self.pct_x, self.pct_16, label='16%', color='orange', linewidth=3, linestyle='--')
        ax.plot(self.pct_x, self.pct_50, label='50%', color='red', linewidth=3)
        ax.plot(self.pct_x, self.pct_84, label='84%', color='green', linewidth=3, linestyle='--')
        ax.set_title('IDA curves')
        ax.legend()
        ax.set_xlim(*self.IDA_range)
        ax.set_ylim(0)
        ax.set_xlabel('EDP')
        ax.set_ylabel('IM')
        # 2 EDP-IM (指数)
        ax: Axes = axes[0, 1]
        ax.plot(self.IM, self.DM, 'o')
        ax.plot(self.IM_fit, self.DM_fit, 'red', label=f'EDP = exp({self.A:.4f} + {self.B:.4f} * ln(IM))')
        ax.set_title('DM - IM curve')
        ax.set_xlabel('IM')
        ax.set_ylabel('EDP')
        ax.legend()
        # 3 ln(EDP)-ln(IM) (线性)
        ax: Axes = axes[0, 2]
        ax.plot(np.log(self.IM), np.log(self.DM), 'o')
        ax.plot(np.log(self.IM_fit), np.log(self.DM_fit), 'red', label=f'ln(EDP) = {self.A:.4f} + {self.B:.4f} * ln(IM)')
        ax.set_xlabel('ln(IM)')
        ax.set_ylabel('ln(EDP)')
        ax.legend()
        # 4 易损性曲线
        ax: Axes = axes[1, 0]
        for i, y in enumerate(self.y_frag):
            ax.plot(self.x_frag, y, label=self.label[i])
            ax.legend()
        ax.legend('Fragility curves')
        ax.set_xlim(0)
        ax.set_ylim(0, 1)
        ax.set_xlabel('Sa(T1)')
        ax.set_ylabel('Exceeding probability')
        # 5 倒塌易损性曲线
        ax: Axes = axes[1, 1]
        if self.Calc_collapse:
            ax.plot(self.x_clps_frag_fit, self.y_clps_frag_fit)
            ax.plot(self.x_clps_frag_real, self.y_clps_frag_real, 'o', color='red')
            ax.set_title('Collapse fragility curve')
            ax.set_xlim(0)
            ax.set_ylim(0)
            ax.set_xlabel('IM')
            ax.set_ylabel('Collapse probability')
        # 6 EDP超越概率
        ax: Axes = axes[1, 2]
        if self.Calc_p:
            ax.plot(self.x_EDP_frag_fit, self.y_EDP_frag_fit)
            ax.plot(self.x_EDP_frag_real, self.y_EDP_frag_real, 'o', color='red')
            ax.set_title(f'Exceedance probability of {self.EDP_val}')
            ax.set_xlim(0)
            ax.set_ylim(0)
            ax.set_xlabel('IM')
            ax.set_ylabel('Exceedance probability')
        # 画图
        plt.tight_layout()
        plt.show()


    def Print_data(self):
        """输出相关统计结果
        """
        self.text = ''
        self.text += '概率地震需求模型参数：\n'
        self.text += f'A = {self.A:.4f}, B = {self.B:.4f}\n'
        self.text += f'a = {self.a:.4f}, b = {self.a:.4f}\n'
        self.text += f'线性拟合R2：{self.R2:.3f}\n'
        if self.Calc_collapse:
            self.text += '\n倒塌易损性参数：\n'
            self.text += f'倒塌均值：{self.clps_point_mean:.3f}g\n'
            self.text += f'倒塌中位值：{self.clps_point_50:.3f}g\n'
            self.text += f'倒塌标准差：{self.clps_point_std:.3f}g\n'
            self.text += f'倒塌裕度比：CMR = {self.CMR:.3f}\n'
        if self.Calc_p:
            self.text += '\nEDP超越概率曲线参数：\n'
            self.text += f'均值：{self.EDP_point_mean:.3f}g\n'
            self.text += f'中位值：{self.EDP_point_50:.3f}g\n'
            self.text += f'标准差：{self.EDP_point_std:.3f}g\n'
        print(self.text)

    def Save_data(self, output_path: str | Path):
        """保存易损性分析结果
            
            Args:
                collapse_state (str | Path): 保存结果的文件夹路径
        """
        output_path = Path(output_path)
        if not Path.exists(output_path):
            Path.mkdir(output_path)
        self.fig.savefig(output_path / 'results.png', dpi=600)
        EDP_name = self.EDP_name[self.EDP_type]
        # IDA曲线
        wb = px.Workbook()
        ws1 = wb.active
        ws1.title = 'IDA曲线'
        for i, (x, y) in enumerate(zip(self.IDA_x, self.IDA_y)):
            ws1.cell(1, 2*i+1, i+1)
            ws1.merge_cells(start_row=1, start_column=2*i+1, end_row=1, end_column=2*i+2)
            for j, (xi, yi) in enumerate(zip(x, y)):
                ws1.cell(j+2, 2*i+1, value=xi)
                ws1.cell(j+2, 2*i+2, value=yi)
        ws2 = wb.create_sheet('分位线')
        ws2.merge_cells(start_row=1, start_column=1, end_row=1, end_column=2)
        ws2.cell(1, 1, '16%分位线')
        ws2.cell(1, 3, '50%分位线')
        ws2.cell(1, 5, '84%分位线')
        for i, (x, y) in enumerate(zip(self.pct_x, self.pct_16)):
            ws2.cell(i+2, 1, x)
            ws2.cell(i+2, 2, y)
        for i, (x, y) in enumerate(zip(self.pct_x, self.pct_50)):
            ws2.cell(i+2, 3, x)
            ws2.cell(i+2, 4, y)
        for i, (x, y) in enumerate(zip(self.pct_x, self.pct_84)):
            ws2.cell(i+2, 5, x)
            ws2.cell(i+2, 6, y)
        wb.save(output_path/f'IDA曲线_{EDP_name}.xlsx')
        # 概率需求模型
        wb = px.Workbook()
        ws1 = wb.active
        ws1.title = 'DM-IM'
        ws1.cell(1, 1, 'DM-IM散点')
        ws1.cell(1, 3, '拟合值')
        ws1.merge_cells(start_row=1, start_column=1, end_row=1, end_column=2)
        ws1.merge_cells(start_row=1, start_column=3, end_row=1, end_column=4)
        for i, (x, y) in enumerate(zip(self.IM, self.DM)):
            ws1.cell(i+2, 1, x)
            ws1.cell(i+2, 2, y)
        for i, (x, y) in enumerate(zip(self.IM_fit, self.DM_fit)):
            ws1.cell(i+2, 3, x)
            ws1.cell(i+2, 4, y)
        ws2 = wb.create_sheet('ln(DM)-ln(IM)')
        ws2.cell(1, 1, 'ln(DM)-ln(IM)散点')
        ws2.cell(1, 3, '拟合值')
        ws2.merge_cells(start_row=1, start_column=1, end_row=1, end_column=2)
        ws2.merge_cells(start_row=1, start_column=3, end_row=1, end_column=4)
        for i, (x, y) in enumerate(zip(np.log(self.IM), np.log(self.DM))):
            ws2.cell(i+2, 1, x)
            ws2.cell(i+2, 2, y)
        for i, (x, y) in enumerate(zip(np.log(self.IM_fit), np.log(self.DM_fit))):
            ws2.cell(i+2, 3, x)
            ws2.cell(i+2, 4, y)
        wb.save(output_path/f'概率需求模型_{EDP_name}.xlsx')
        # 地震易损性、倒塌易损性曲线
        wb = px.Workbook()
        ws1 = wb.active
        ws1.title = '地震易损性'
        ws1.cell(1, 1, 'IM')
        ws1.cell(1, 2, '超越概率')
        ws1.merge_cells(start_row=1, start_column=1, end_row=2, end_column=1)
        ws1.merge_cells(start_row=1, start_column=2, end_row=1, end_column=1+len(self.label))
        for i, label in enumerate(self.label):
            ws1.cell(2, i+2, label)
        for i, x in enumerate(self.x_frag):
            ws1.cell(3+i, 1, x)
        for i in range(len(self.y_frag)):
            for j, y in enumerate(self.y_frag[i]):
                ws1.cell(3+j, i+2, y)
        if self.Calc_collapse:
            ws2 = wb.create_sheet('倒塌易损性')
            ws2.cell(1, 1, '实际(散点)')
            ws2.cell(1, 3, '拟合(曲线)')
            ws2.merge_cells(start_row=1, start_column=1, end_row=1, end_column=2)
            ws2.merge_cells(start_row=1, start_column=3, end_row=1, end_column=4)
            for i, (x, y) in enumerate(zip(self.x_clps_frag_real, self.y_clps_frag_real)):
                ws2.cell(2+i, 1, x)
                ws2.cell(2+i, 2, y)
            for i, (x, y) in enumerate(zip(self.x_clps_frag_fit, self.y_clps_frag_fit)):
                ws2.cell(2+i, 3, x)
                ws2.cell(2+i, 4, y)
        wb.save(output_path/f'易损性曲线_{EDP_name}.xlsx')
        # 任意EDP超越概率
        wb = px.Workbook()
        if self.Calc_p:
            ws = wb.active
            ws.title = f'超越概率曲线({self.EDP_val})'
            ws.cell(1, 1, '实际(散点)')
            ws.cell(1, 3, '拟合(曲线)')
            ws.merge_cells(start_row=1, start_column=1, end_row=1, end_column=2)
            ws.merge_cells(start_row=1, start_column=3, end_row=1, end_column=4)
            for i, (x, y) in enumerate(zip(self.x_EDP_frag_real, self.y_EDP_frag_real)):
                ws.cell(2+i, 1, x)
                ws.cell(2+i, 2, y)
            for i, (x, y) in enumerate(zip(self.x_EDP_frag_fit, self.y_EDP_frag_fit)):
                ws.cell(2+i, 3, x)
                ws.cell(2+i, 4, y)
        wb.save(output_path/f'EDP超越概率曲线.xlsx')
        # 保存计算结果参数
        with open(output_path/'计算结果参数.txt', 'w') as f:
            f.write(self.text)
        logger.success('已保存数据')




if __name__ == "__main__":

    # 层间位移角
    Model_4StoryMRF = FragilityAnalysis(r'H:\MRF_results\4SMRF_AE_noSPD_out', EDP_type=1)
    Model_4StoryMRF.calc_IDA(DM_limit=0.1)
    Model_4StoryMRF.frag_curve(
        Damage_State=[0.005, 0.01, 0.02, 0.04],
        label=['DS-1', 'DS-2', 'DS-3', 'DS-4']
    )
    Model_4StoryMRF.frag_collapse(IM_MCE=[0.5631186282943467*1.5])
    Model_4StoryMRF.exceedance_probability(EDP_val=0.15)
    Model_4StoryMRF.PlotCurves()
    Model_4StoryMRF.Print_data()
    Model_4StoryMRF.Save_data(r'H:\MRF_results\4SMRF_AE_noSPD_out_frag')

    # 层加速度
    # Model_4StoryMRF = FragilityAnalysis(r'H:\MRF_results\4StoryMRF_out', EDP_type=3)
    # Model_4StoryMRF.calc_IDA(DM_limit=7, slope_limit=0.01)
    # Model_4StoryMRF.frag_curve(
    #     Damage_State=[0.005, 0.01, 0.02, 0.04],
    #     label=['DS-1', 'DS-2', 'DS-3', 'DS-4']
    # )
    # Model_4StoryMRF.frag_collapse(IM_MCE=[0.5631186282943467*1.5])
    # Model_4StoryMRF.exceedance_probability(EDP_val=4)
    # Model_4StoryMRF.beam_damage(EDP_theta=[0.04, 0.06])
    # Model_4StoryMRF.PlotCurves()
    # Model_4StoryMRF.Print_data()
    # Model_4StoryMRF.Save_data(r'H:\MRF_results\4StoryMRF_frag')


    