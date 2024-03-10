def interpolation(x1: float, y1: float, x2: float, y2: float, xi: float) -> float:
    """线性差值

    Args:
        x1 (float): 已知点坐标
        y1 (float): 已知点坐标
        x2 (float): 已知点坐标
        y2 (float): 已知点坐标
        xi (float): 输入点横坐标

    Returns:
        float: 输出点横坐标
    """
    k = (y2 - y1) / (x2 - x1)
    yi = k * (xi - x1) + y1
    return yi