from collections import namedtuple
from typing import Iterable, Self

import numpy as np
from scipy.stats import linregress


Point = namedtuple('Point', ['x', 'y'])


class Curve():
    """曲线类"""
    def __init__(self, x: list[float]=None, y: list[float]=None,
                 name: str='Unnamed'):
        self.name = name  # 曲线名称
        if x is None or y is None:
            self.data = np.zeros((0, 2))
        else:
            self.data = np.array(list(zip(x, y)))

    @classmethod
    def from_points(cls, points: list[Point], name: str=None) -> Self:
        obj = cls(None, None, name)
        obj.add_points(points)
        return obj

    @property
    def x(self) -> np.ndarray:
        """横坐标"""
        return self.data[:, 0]

    @property
    def y(self) -> np.ndarray:
        """纵坐标"""
        return self.data[:, 1]

    def get_xy(self) -> tuple[np.ndarray, np.ndarray]:
        """获取曲线的横纵坐标

        Returns:
            tuple[np.ndarray, np.ndarray]: 曲线的横纵坐标
        """
        return self.x, self.y

    def add_points(self, points: list[Point]):
        x, y = zip(*points)
        self.data = np.append(self.data, np.array(list(zip(x, y))), axis=0)

    def add_point(self, point: Point):
        x, y = point
        self.data = np.append(self.data, np.array([[x, y]]), axis=0)

    def sort_by_x(self, reverse=False, in_place=True) -> None | Self:
        """按横坐标排序

        Args:
            reverse (bool, optional): 是否按降序排序，默认False，即升序排序
            in_place (bool, optional): 是否修改原Curve对象
        """
        sorted_indices = np.argsort(self.x)
        new_x = self.x[sorted_indices]
        new_y = self.y[sorted_indices]
        if reverse:
            new_x = new_x[::-1]
            new_y = new_y[::-1]
        if in_place:
            self.data = np.array(list(zip(new_x, new_y)))
        else:
            return Curve(new_x, new_y, self.name)

    def logarithmize(self, in_place=False) -> None | Self:
        """对数变换

        Args:
            in_place (bool, optional): 是否修改原对象
            
        Returns:
            None | Self: 如果in_place为False，返回新的Curve对象，否则返回None
        """
        log_x = np.log(self.x)
        log_y = np.log(self.y)
        if in_place:
            self.data = np.array(list(zip(log_x, log_y)))
        else:
            return Curve(log_x, log_y, self.name)

    def linear_fitting(self) -> tuple[float, float, float, float, float]:
        """线性拟合

        Returns:
            tuple[float, float, float, float, float]: 斜率、截距、相关系数、
              回归标准差
        """
        x, y = self.get_xy()
        results = linregress(x, y)
        slope, intercept, rvalue, _, _ = map(float, results)
        y_pred = slope * x + intercept
        N = len(self)
        RSS = np.sum((y - y_pred) ** 2)
        rse = np.sqrt(RSS / (N - 2))
        return slope, intercept, rvalue, rse
    
    def interpolate(self,
                    x: float | np.ndarray = None,
                    y: float | np.ndarray = None
        ) -> np.float64 | np.ndarray:
        if x is None and y is None:
            raise ValueError("Either x or y must be provided")
        if x is not None and y is not None:
            raise ValueError("Either x or y must be provided, not both")
        if x is not None:
            return np.interp(x, self.x, self.y, left=np.nan, right=np.nan)
        else:
            return np.interp(y, self.y, self.x, left=np.nan, right=np.nan)

    def plot(self, *args, **kwargs):
        """绘图"""
        import matplotlib.pyplot as plt
        x, y = self.get_xy()
        plt.plot(x, y, *args, **kwargs)
        plt.xlabel('x')
        plt.ylabel('y')
        plt.title('Curve Visualization')
        plt.grid(True)
        plt.tight_layout()
        plt.show()

    def __len__(self) -> int:
        return self.data.shape[0]

    def __getitem__(self, index: int | slice) -> Point | Self:
        """索引和切片
        
        当使用整数索引时，返回单个 Point 对象
        当使用切片时，返回包含切片点的新 Curve 对象
        """
        x, y = self.data[index].T
        if isinstance(index, int):
            return Point(x, y)
        elif isinstance(index, slice):
            return Curve(x, y, self.name)
        else:
            raise TypeError("Indices must be integers or slices")

    def __delitem__(self, index: int | slice):
        self.data = np.delete(self.data, index, axis=0)

    def __iter__(self):
        for x, y in self.data:
            yield Point(x, y)

    def __repr__(self) -> str:
        return f'Curve "{self.name}":\n{self.data}'

    def __str__(self) -> str:
        return f'Curve "{self.name}":\n{self.data}'


class AutoDict(dict):
    """自动创建嵌套字典"""
    def __missing__(self, key):
        self[key] = AutoDict()
        return self[key]
