import numpy as np
import pandas as pd
from PIL import Image
from typing import Literal


class Records:
    name: str
    N_gm: int
    info: pd.DataFrame
    unscaled_data: list[np.ndarray]
    unscaled_spec: list[np.ndarray]
    SF: list[float]
    dt: list[float]
    type_: list[Literal['A', 'V', 'D']]
    selecting_text: str
    target_spec: np.ndarray
    individual_spec: np.ndarray
    mean_spec: np.ndarray
    img: Image
    def __init__(self, name: str = None) -> None: ...
    def plot_spectra(self) -> None:
        """绘制反应谱曲线"""
        ...
    def get_unscaled_records(self) -> zip[tuple[np.ndarray, float]]:
        """导出未缩放的时程

        Returns:
            zip[tuple[np.ndarray, float]]: 时程序列，步长

        Examples:
            >>> for data, dt in get_unscaled_records():
                    print(data.shape, dt)
        """
        ...
    def get_scaled_records(self) -> zip[tuple[np.ndarray, float]]:
        """导出缩放后的时程

        Returns:
            zip[tuple[np.ndarray, float]]: 时程序列，步长

        Examples:
            >>> for data, dt in get_scaled_records():
                    print(data.shape, dt)
        """
        ...
    def get_normalised_records(self) -> zip[tuple[np.ndarray, float]]:
        """导出归一化的时程

        Returns:
            zip[tuple[np.ndarray, float]]: 时程序列，步长

        Examples:
            >>> for data, dt in get_normalised_records():
                    print(data.shape, dt)
        """
        ...
