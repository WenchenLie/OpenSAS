import os
import sys
from pathlib import Path

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.axes import Axes
from matplotlib.figure import Figure
from scipy.stats import norm
import openpyxl as px
from loguru import logger
from wsection import WSection
if __name__ == "__main__":
    sys.path.append(str(Path(__file__).parent.parent))

"""
最后更新：
2024-04-07: 优化画图代码，增加保存结果图像文件
2024-05-31: 功能增强，可同时处理多种工程需求参数类型，代码结构优化
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
    available_DM_types = ['IM', 'IDR', 'DCF', 'PFV', 'PFA', 'ResIDR', 'RoofIDR' ,'Shear', 'beamHinge', 'colHinge', 'panelZone']  # 允许的DM类型

    def __init__(self, root: str | Path, DM_types: list[str],
                 collapse_limit: float=None, additional_items: list[str]=None):
        """地震易损性、倒塌易损性分析

        Args:
            root (str | Path): 待读取数据的文件夹的路径
            DM_types (list[str]): 工程需求参数类型
            * [IDR] - 层间位移角
            * [DCF] - 层间变形集中系数
            * [PFV] - 层间速度
            * [PFA] - 楼层绝对加速度
            * [ResIDR] - 残余层间位移角
            * [RoofIDR] - 屋顶层间位移角
            * [Shear] - 层间剪力
            * [beamHinge] - 最大梁铰变形
            * [colHinge] - 最大柱铰变形
            * [panelZone] - 最大节点域变形
            * additional_item - 其他项\n
            collapse_limit (float, optional): 倒塌极限层间位移角，如果给定DM对应的层间位移角角大于给定值，
            则不统计，可设为0.1或0.15，默认为None，即不删除倒塌点之后的点\n
            additional_items (list[str], optional): 其他的要读取的项
        """
        for DM_name in DM_types:
            if not DM_name in self.available_DM_types:
                raise ValueError(f'`DM_name`不是可用的类型')
        self.Calc_collapse = False  # 是否有进行倒塌易损性计算
        self.Calc_p = False  # 是否有进行EDP超越概率计算
        self.root = Path(root)
        self.DM_types = DM_types
        self.collapse_limit = collapse_limit
        self.additional_items = additional_items
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
        """读取结果文件"""
        # 读取数据
        self.data: list[pd.DataFrame] = []  # 包含所有时程结果的最值
        columns = self.available_DM_types
        if self.additional_items:
            columns += self.additional_items
        for idx_gm in range(self.GM_N):
            # 遍历地震动
            gm_name = self.GM_names[idx_gm]
            print(f'  正在读取: {gm_name}    \r', end='')
            num =  1
            df = pd.DataFrame(columns=columns)
            while True:
                # 遍历每个动力增量
                folder = self.root / f'{gm_name}_{num}'
                if not Path.exists(folder):
                    break
                line = []
                IM = np.loadtxt(folder/'Sa.out')  # 地震动强度指标
                IM = round(float(IM), 6)
                line.append(IM)
                IDR = np.loadtxt(folder/'层间位移角.out')  # 层间位移角
                line.append(np.max(np.abs(IDR)))
                DCF = np.loadtxt(folder/'DCF.out')  # 层间变形集中系数
                line.append(np.max(np.abs(DCF)))
                PFV = np.loadtxt(folder/'层速度.out')  # 层间相对速度
                line.append(np.max(np.abs(PFV)))
                PFA = np.loadtxt(folder/'层加速度(g).out')  # 层间相对加速度
                line.append(np.max(np.abs(PFA)))
                ResIDR = np.loadtxt(folder/'残余层间位移角.out')  # 残余层间位移角
                line.append(np.max(np.abs(ResIDR)))
                RoofIDR = np.loadtxt(folder/'屋顶层间位移角.out')  # 屋顶层间位移角
                line.append(np.max(np.abs(RoofIDR)))
                Shear = np.loadtxt(folder/'楼层剪力(kN).out')  # 层间剪力
                line.append(np.max(np.abs(Shear)))
                beamHinge = np.loadtxt(folder/'梁铰变形.out')  # 梁铰变形
                line.append(np.max(np.abs(beamHinge)))
                colHinge = np.loadtxt(folder/'柱铰变形.out')  # 柱铰变形
                line.append(np.max(np.abs(colHinge)))
                panelZone = np.loadtxt(folder/'节点域变形.out')  # 节点域变形
                line.append(np.max(np.abs(panelZone)))
                if self.additional_items:
                    for item in self.additional_items:
                        if not (folder/f'{item}.out').exists():
                            raise FileExistsError(f'无法找到文件:', str((folder/f'{item}.out').absolute()))
                        data = np.loadtxt(folder/f'{item}.out')  # 其他的要读取的项
                        line.append(np.max(np.abs(data)))
                df.loc[len(df)] = line
                num += 1
            df = df.sort_values(by='IM')  # 每条地震波按IM列的大小排序
            df.index = [i for i in range(1, len(df) + 1)]  # 重新指定index
            for idx, line in df.iterrows():
                if line['IDR'] >= self.collapse_limit:
                    break
            df = df[df.index<=idx]  # 删除倒塌点之后的数据
            self.data.append(df)
        logger.success('已读取数据')


    def calc_IDA(self):
        """计算IDA曲线簇
        """
        self.IM_scatter, self.DM_scatter = {}, {}
        self.IM_lines, self.DM_lines = {}, {}
        self.pct_x, self.pct_16, self.pct_50, self.pct_84 = {}, {}, {}, {}
        for DM_name in self.DM_types:
            # 遍历DM类型
            print(f'  正在计算`{DM_name}`类型的IDA曲线      \r', end='')
            IM_scatter, DM_scatter = [], []  # 所有IDA曲线的散点坐标
            IM_lines, DM_lines = [], []  # IDA曲线簇(多条)
            for df in self.data:
                IM_scatter += df['IM'].to_list()
                DM_scatter += df[DM_name].to_list()
                IM_lines.append([0] + df['IM'].to_list())
                DM_lines.append([0] + df[DM_name].to_list())
                pct_x, pct_16 = get_percentile_line(DM_lines, IM_lines, p=16, n=300, x0=0, x1=min([max(i) for i in DM_lines]))
                pct_x, pct_50 = get_percentile_line(DM_lines, IM_lines, p=50, n=300, x0=0, x1=min([max(i) for i in DM_lines]))
                pct_x, pct_84 = get_percentile_line(DM_lines, IM_lines, p=84, n=300, x0=0, x1=min([max(i) for i in DM_lines]))
            self.IM_scatter[DM_name] = IM_scatter
            self.DM_scatter[DM_name] = DM_scatter
            self.IM_lines[DM_name] = IM_lines
            self.DM_lines[DM_name] = DM_lines
            self.pct_x[DM_name] = pct_x
            self.pct_16[DM_name] = pct_16
            self.pct_50[DM_name] = pct_50
            self.pct_84[DM_name] = pct_84
        logger.success('已计算IDA曲线')


    def frag_curve(self, damage_states: dict[str, list[float]], labels: dict[str, list[str]], betaDC: float=0.4):
        """对概率需求模型进行拟合，计算易损性曲线

        Args:
            damage_states (dict[str, list[float]]): 不同损伤状态对应的EDP\n
            labels (dict[str, list[str]]): 不同损伤状态对应的描述\n
            betaDC (float, optional): 表征不确定性的标准差(默认0.4)
        """
        keys = list(damage_states.keys()) + list(labels.keys())
        for key in keys:
            if not key in self.DM_types:
                raise KeyError(f'尚未指定`{key}`类型，请在`__init__`方法的`DM_types`参数中添加')
        self.damage_states = damage_states
        self.labels = labels
        self.A, self.B = {}, {}  # ln(DM) = A + B * ln(IM)
        self.R2 = {}  # R方
        self.ln_IM_fit, self.ln_DM_fit = {}, {}
        self.x_frag: dict[str, np.ndarray] = {}
        self.y_frag: dict[str, list[np.ndarray]] = {}
        self.info: dict[str, str] = {}  # 记录拟合参数
        for key in self.DM_types:
            DM_name = key  # 损伤指标名称
            DS = damage_states[DM_name]  # 损伤状态值
            print(f'  正在计算`{DM_name}`类型的易损性曲线和概率需求模型      \r', end='')
            IM = self.IM_scatter[DM_name]
            DM = self.DM_scatter[DM_name]
            IM1 = min(IM)
            # 地震易损性曲线的横坐标最大范围(取为84分位线的最大IM值的1.5倍)
            IM2_for_frag_curve = get_y(self.pct_x[DM_name], self.pct_84[DM_name], max(DS)) * 1.5
            # 概率需求模型曲线的横坐标最大范围(取为最大IM值)
            IM2_for_prob_curve = max(IM)
            ln_IM_fit = np.linspace(IM1, IM2_for_prob_curve, 1001)
            ln_IM, ln_DM = np.log(IM), np.log(DM)
            n = len(ln_IM)
            B = (n * sum(ln_IM * ln_DM) - sum(ln_IM) * sum(ln_DM)) / (n * sum(ln_IM**2) - sum(ln_IM)**2)
            A = (sum(ln_DM) - B * sum(ln_IM)) / n
            ln_DM_pre = A + B * ln_IM
            SSR = np.sum((ln_DM - ln_DM_pre) ** 2)
            SST = np.sum((ln_DM - np.mean(ln_DM_pre)) ** 2)
            R2 = 1 - (SSR / SST)
            x_frag = np.linspace(0.001, IM2_for_frag_curve * 1.2, 1000)  # 易损性曲线x轴
            y_frag = []  # 易损性曲线y轴
            for _, DS_i in enumerate(DS):
                y_frag.append(norm.cdf((A + B * np.log(x_frag) - np.log(DS_i)) / betaDC, 0, 1))  # 易损性曲线y轴
            # DM和IM的对数关系
            ln_DM_fit = np.exp(A + B * np.log(ln_IM_fit))
            self.A[DM_name] = A
            self.B[DM_name] = B
            self.R2[DM_name] = R2
            self.ln_IM_fit[DM_name] = ln_IM_fit
            self.ln_DM_fit[DM_name] = ln_DM_fit
            self.x_frag[DM_name] = x_frag
            self.y_frag[DM_name] = y_frag
            self.info[DM_name] = f'类型`{DM_name}`\n\n概率模型需求参数(ln(DM) = A + B * ln(IM))：\nA = {A:.6f}\nB = {B:.6f}\n\n'
        logger.success('已完成易损性函数计算和概率需求模型的拟合')


    def exceedance_probability(self, DM_values: dict[str, float]):
        """计算所有损伤指标超越某值的概率

        Args:
            DM_values (float): 损伤指标超越DM_value的概率
        """
        for key in DM_values.keys():
            if not key in self.DM_types:
                raise KeyError(f'尚未指定`{key}`类型，请在`__init__`方法的`DM_types`参数中添加')
        self.exceed_mean, self.exceed_std, self.exceed_pct50 = {}, {}, {}  # 均值、标准差、中位值
        self.exceed_x, self.exceed_y = {}, {}  # 超越概率点的横纵坐标
        self.exceed_x_fit, self.exceed_y_fit = {}, {}  # 超越概率点的拟合曲线横纵坐标
        for n, key in enumerate(self.DM_types):
            DM_name = key  # 损伤指标名称
            DM_value = DM_values[DM_name]
            # 以直线x=DM_value切割所有IDA曲线，获得交点
            IM_lines, DM_lines = self.IM_lines[key], self.DM_lines[key]  # 所有IDA曲线
            if DM_value < min([min(i) for i in DM_lines]):
                raise ValueError(f'`{DM_name}`类型的`{DM_value}`值小于所有IDA曲线的最小DM值({min([max(i) for i in DM_lines])})')
            if DM_value > max([max(i) for i in DM_lines]):
                raise ValueError(f'`{DM_name}`类型的`{DM_value}`值大于所有IDA曲线的最大DM值({max([max(i) for i in DM_lines])})')
            IM_points = []  # 交点对应的IM纵坐标列表
            for i in range(self.GM_N):
                IM_line, DM_line = IM_lines[i], DM_lines[i]  # 单调IDA曲线
                try:
                    y = get_y(DM_line, IM_line, DM_value)
                    IM_points.append(y)
                except ValueError:
                    logger.warning(f'`{DM_name}`类型的`{DM_value}`值不在第{i+1}条IDA曲线的DM范围内({min(DM_line)}, {max(DM_line)})')
            if len(IM_points) < self.GM_N:
                logger.error(f'将不进行`{DM_name}`类型的超越概率统计')
                continue
            exceed_mean, exceed_std, exceed_pct50 = np.mean(IM_points), np.std(IM_points), np.percentile(IM_points, 50)  # 均值、标准差、中位值
            exceed_x = sorted(IM_points)  # 超越概率点横坐标(IM)
            exceed_y = np.array([i/self.GM_N for i in range(1, self.GM_N+1)])  # 超越概率点纵坐标(超越概率)
            # 拟合超越概率曲线
            ln_theta = 1 / len(exceed_x) * sum(np.log(exceed_x))
            theta = np.exp(ln_theta)
            beta = np.sqrt(1 / len(exceed_x) * sum((np.log(exceed_x / theta))**2))
            IM1, IM2 = 0.001, max(exceed_x) * 1.2  # 坐标范围
            exceed_x_fit = np.linspace(IM1, IM2, 1001)  # 超越概率曲线横坐标(IM)
            exceed_y_fit = norm.cdf(np.log(exceed_x_fit / theta) / beta, 0, 1)  # 超越概率曲线横坐标(超越概率)
            text = ''  # 统计特征的文本
            text += f'`{DM_name}`超越{DM_value}的概率特征：\n'
            text += f'均值：{exceed_mean:.6f}\n'
            text += f'标准差：{exceed_std:.6f}\n'
            text += f'中位值：{exceed_pct50:.6f}\n\n'
            print(text)
            self.exceed_mean[DM_name] = exceed_mean
            self.exceed_std[DM_name] = exceed_std
            self.exceed_pct50[DM_name] = exceed_pct50
            self.exceed_x[DM_name] = exceed_x
            self.exceed_y[DM_name] = exceed_y
            self.exceed_x_fit[DM_name] = exceed_x_fit
            self.exceed_y_fit[DM_name] = exceed_y_fit
            self.info[DM_name] += text
            self.DM_values = DM_values
        logger.success('已计算超越概率曲线')


    def visualization(self, plot_IDA_idx: int=None):
        """可视化曲线图

        Args:
            plot_IDA_idx (int, optional): 如果指定，则绘制索引为`plot_IDA_idx`的IDA曲线
        """
        self.figs: dict[str, Figure] = {}
        for DM_name in self.DM_types:
            fig, axes = plt.subplots(nrows=2, ncols=2, figsize=(16, 12))
            # 1 IDA曲线
            ax: Axes = axes[0, 0]
            for i, (x, y) in enumerate(zip(self.DM_lines[DM_name], self.IM_lines[DM_name])):
                if plot_IDA_idx == i:
                    ax.plot(x, y, color='blue', markersize=6, label=f'idx={i}', zorder=9999)
                else:
                    ax.plot(x, y, color='#BFBFBF', markersize=4)
                ax.scatter(x, y, color='red', zorder=8999, s=7)
            ax.plot(self.pct_x[DM_name], self.pct_16[DM_name], label='16%', color='green', linewidth=3, linestyle='--')
            ax.plot(self.pct_x[DM_name], self.pct_50[DM_name], label='50%', color='green', linewidth=3)
            ax.plot(self.pct_x[DM_name], self.pct_84[DM_name], label='84%', color='green', linewidth=3, linestyle='--')
            ax.set_title(f'IDA curves ({DM_name})')
            ax.legend()
            if DM_name == 'IDR':
                ax.set_xlim(0, self.collapse_limit)
            else:
                ax.set_xlim(0)
            ax.set_ylim(0)
            ax.set_xlabel('DM')
            ax.set_ylabel('IM')
            # 2 ln(DM)-ln(IM) (线性)
            ax: Axes = axes[0, 1]
            ax.plot(np.log(self.IM_scatter[DM_name]), np.log(self.DM_scatter[DM_name]), 'o')
            ax.plot(np.log(self.ln_IM_fit[DM_name]), np.log(self.ln_DM_fit[DM_name]), 'red', label=f'ln(DM) = {self.A[DM_name]:.4f} + {self.B[DM_name]:.4f} * ln(IM)')
            ax.set_title('ln(DM) - ln(IM)')
            ax.set_xlabel('ln(IM)')
            ax.set_ylabel('ln(DM)')
            ax.legend()
            # 3 易损性曲线
            ax: Axes = axes[1, 0]
            x_frag = self.x_frag[DM_name]
            for i, y_frag in enumerate(self.y_frag[DM_name]):
                ax.plot(x_frag, y_frag, label=f'{self.labels[DM_name][i]} ({self.damage_states[DM_name][i]})')
                ax.legend()
            ax.set_title('Fragility curves')
            ax.set_xlim(0)
            ax.set_ylim(0, 1)
            ax.set_xlabel('Sa(T1)')
            ax.set_ylabel('Exceeding probability')
            # 4 DM超越概率
            ax: Axes = axes[1, 1]
            ax.set_title(f'Exceedance probability of {DM_name}')
            ax.set_xlabel('IM')
            ax.set_ylabel('Exceedance probability')
            if DM_name in self.exceed_x_fit.keys():
                ax.plot(self.exceed_x_fit[DM_name], self.exceed_y_fit[DM_name])
                ax.plot(self.exceed_x[DM_name], self.exceed_y[DM_name], 'o', color='red')
                ax.set_xlim(0)
                ax.set_ylim(0)
            # 画图
            plt.tight_layout()
            plt.show()
            self.figs[DM_name] = fig


    def collapse_evaluation(self, T1: float, MCE_spec: Path | str, SF_spec: float=1):
        """抗倒塌性能评估

        Args:
            T1 (float): 结构一阶周期
            MCE_spec (Path | str): MCE规范谱所在文件路径(文件为两列，一列周期一列谱值)
            SF_spec (float, optional): 将规范谱的谱值进行放大，默认放大系数为1
        """
        MCE_spec = Path(MCE_spec)
        if not MCE_spec.exists():
            raise FileExistsError(f'无法找到文件：{str(MCE_spec.absolute())}')
        if 'IDR' not in self.DM_types:
            raise ValueError('未进行`IDR`类型的易损性分析')
        spec_data = np.loadtxt(MCE_spec)
        spec_data[:, 1] *= SF_spec
        Sa_MCE = get_y(spec_data[:, 0], spec_data[:, 1], T1)  # 一阶周期对应的MCE谱谱值
        CMR = get_x(self.exceed_x_fit['IDR'], self.exceed_y_fit['IDR'], 0.5) / Sa_MCE
        print(f'倒塌储备系数(CMR)：{CMR:.3f}')


    def save_data(self, output_path: str | Path):
        """保存分析结果
            
            Args:
                collapse_state (str | Path): 保存结果的文件夹路径
        """
        output_path = Path(output_path)
        if not Path.exists(output_path):
            os.makedirs(output_path)
        print('正在保存数据...\r', end='')
        for DM_name in self.DM_types:
            self.figs[DM_name].savefig(output_path / f'figures_{DM_name}.png', dpi=600)  # 保存曲线图
            # 1 IDA曲线
            wb = px.Workbook()
            ws1 = wb.active
            ws1.title = 'IDA曲线'
            for i, (x, y) in enumerate(zip(self.DM_lines[DM_name], self.IM_lines[DM_name])):
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
            for i, (x, y) in enumerate(zip(self.pct_x[DM_name], self.pct_16[DM_name])):
                ws2.cell(i+2, 1, x)
                ws2.cell(i+2, 2, y)
            for i, (x, y) in enumerate(zip(self.pct_x[DM_name], self.pct_50[DM_name])):
                ws2.cell(i+2, 3, x)
                ws2.cell(i+2, 4, y)
            for i, (x, y) in enumerate(zip(self.pct_x[DM_name], self.pct_84[DM_name])):
                ws2.cell(i+2, 5, x)
                ws2.cell(i+2, 6, y)
            wb.save(output_path / f'IDA曲线_{DM_name}.xlsx')
            # 2 概率需求模型
            wb = px.Workbook()
            ws = wb.active
            ws.title = 'ln(DM)-ln(IM)'
            ws.cell(1, 1, 'ln(DM)-ln(IM)散点')
            ws.cell(1, 3, '拟合值')
            ws.merge_cells(start_row=1, start_column=1, end_row=1, end_column=2)
            ws.merge_cells(start_row=1, start_column=3, end_row=1, end_column=4)
            for i, (x, y) in enumerate(zip(np.log(self.IM_scatter[DM_name]), np.log(self.DM_scatter[DM_name]))):
                ws.cell(i+2, 1, x)
                ws.cell(i+2, 2, y)
            for i, (x, y) in enumerate(zip(np.log(self.ln_IM_fit[DM_name]), np.log(self.ln_DM_fit[DM_name]))):
                ws.cell(i+2, 3, x)
                ws.cell(i+2, 4, y)
            wb.save(output_path / f'概率需求模型_{DM_name}.xlsx')
            # 3 地震易损性、超越概率(倒塌易损性)
            wb = px.Workbook()
            ws1 = wb.active
            ws1.title = '地震易损性'
            ws1.cell(1, 1, 'IM')
            ws1.cell(1, 2, '超越概率')
            ws1.merge_cells(start_row=1, start_column=1, end_row=2, end_column=1)
            ws1.merge_cells(start_row=1, start_column=2, end_row=1, end_column=1+len(self.labels[DM_name]))
            for i, label in enumerate(self.labels[DM_name]):
                ws1.cell(2, i+2, label)
            for i, x in enumerate(self.x_frag[DM_name]):
                ws1.cell(3+i, 1, x)
            for i in range(len(self.y_frag[DM_name])):
                for j, y in enumerate(self.y_frag[DM_name][i]):
                    ws1.cell(3+j, i+2, y)
            if DM_name in self.exceed_x.keys():
                ws2 = wb.create_sheet(f'超越概率({DM_name}>{self.DM_values[DM_name]})')
                ws2.cell(1, 1, '实际(散点)')
                ws2.cell(1, 3, '拟合(曲线)')
                ws2.merge_cells(start_row=1, start_column=1, end_row=1, end_column=2)
                ws2.merge_cells(start_row=1, start_column=3, end_row=1, end_column=4)
                for i, (x, y) in enumerate(zip(self.exceed_x[DM_name], self.exceed_y[DM_name])):
                    ws2.cell(2+i, 1, x)
                    ws2.cell(2+i, 2, y)
                for i, (x, y) in enumerate(zip(self.exceed_x_fit[DM_name], self.exceed_y_fit[DM_name])):
                    ws2.cell(2+i, 3, x)
                    ws2.cell(2+i, 4, y)
            wb.save(output_path / f'易损性曲线_{DM_name}.xlsx')
            # 保存计算结果参数
            with open(output_path / f'概率特征_{DM_name}.out', 'w') as f:
                f.write(self.info[DM_name])
        logger.success('已保存数据')



if __name__ == "__main__":

    model = FragilityAnalysis(
        r'H:\RockingFrameWithRSRD\MRF4S_AS_RD_out',
        DM_types=['IDR', 'ResIDR', 'PFA', 'DCF'],
        collapse_limit=0.1,
        additional_items=[])
    model.calc_IDA()
    model.frag_curve(
        damage_states={'IDR': [0.005, 0.01, 0.02, 0.04],
                      'ResIDR': [0.002, 0.005],
                      'PFA': [0.1, 0.2, 0.3],
                      'DCF': [1.001]},
        labels={'IDR': ['DS-1', 'DS-2', 'DS-3', 'DS-4'],
               'ResIDR': ['DS-1', 'DS-2'],
               'PFA': ['DS-1', 'DS-2', 'DS-3'],
               'DCF': ['DS-1']}
    )
    model.exceedance_probability(
        DM_values={'IDR': 0.1, 'ResIDR': 0.005, 'PFA': 0.2, 'DCF': 1.001},
    )
    model.collapse_evaluation(T1=1.2, MCE_spec=r'F:\Projects\MRF\data\DBE_AS.txt', SF_spec=1.5)
    model.visualization()
    model.save_data(r'H:\RockingFrameWithRSRD\MRF4S_AS_RD_frag')


    