import openseespy.opensees as ops
from typing import Dict
import matplotlib.pyplot as plt
from matplotlib.axes import Axes


def DisplayModel2D(model_data_init: tuple, ax: Axes):
    node_info_init: Dict[int, list[float, float]]
    ele_info_init: Dict[int, tuple[float, float, float, float]]
    model_size_init: tuple[float, float, float, float]
    node_info_init, ele_info_init, model_size_init = model_data_init
    ax.set_xlim(-1.4 * model_size_init[0], 1.4 * model_size_init[1])
    ax.set_ylim(-1.2 * model_size_init[2], 1.2 * model_size_init[3])
    for _, (x, y) in node_info_init.items():
        ax.scatter(x, y)
        plt.draw()
        # 无法在子线程中画图



def get_model_data():

    # 获取节点信息
    node_info: Dict[int, list[float, float]] = {}
    node_tags: list = ops.getNodeTags()
    for i, tag in enumerate(node_tags):
        node_info[tag] = ops.nodeCoord(tag)

    # 获取单元信息
    ele_info: Dict[int, tuple[float, float, float, float]] = {}
    ele_tags: list = ops.getEleTags()
    for i, tag in enumerate(ele_tags):
        inode, jnode = ops.eleNodes(tag)
        x1, y1 = node_info[inode]
        x2, y2 = node_info[jnode]
        ele_info[tag] = (x1, y1, x2, y2)

    # 获取模型尺寸范围
    x_max, x_min = 0, 0
    y_max, y_min = 0, 0
    for key, val in node_info.items():
        x, y = val
        x_max = max(x_max, x)
        x_min = min(x_min, x)
        y_max = max(y_max, y)
        y_min = min(y_min, y)
    model_size = (x_min, x_max, y_min, y_max)

    return node_info, ele_info, model_size

