def get_section(N: int, type_: str, story: int=None, floor: int=None, span: int=None, axis: int=None, form: str=None):
    """获取框架的截面名称

    Args:
        N (int): 总层数
        type_ (str): 构件类型(beam, column, panelzone)
        story (int, optional): 结构层
        floor (int, optional): 几楼
        span (int, optional): 第几跨
        axis (int, optional): 第几轴(1-4)
        form (str, optional): 特殊型式(对柱，为bottom或top或None)

    Return:
        str | float: 截面型号或节点域面积
    """
    def check_input(type_, story, floor, span, axis):
        # 检查输入的部件位置是否有误
        if type_ == 'beam':
            if not all([floor, span]):
                raise ValueError('【Error】beam类型需指定floor和span')
        elif type_ == 'column':
            if not all([axis, story]):
                raise ValueError('【Error】column类型需指定axis和story')
        elif type_ == 'panelzone':
            if not all([floor, axis]):
                raise ValueError('【Error】panelzone类型需指定axis和floor')
    section = None
    # ------------------ 4层框架 ----------------------------
    if N == 4:
        if type_ == 'beam':
            check_input(type_, story, floor, span, axis)
            if floor in [2, 3]:
                section = 'W24x76'
            elif floor in [4, 5]:
                section = 'W18x60'
        elif type_ == 'column':
            check_input(type_, story, floor, span, axis)
            if axis in [1, 4] and story in [1, 2]:
                section = 'W24x103'
            elif axis in [2, 3] and story in [1, 2]:
                section = 'W24x146'
            elif axis in [1, 4] and story == 3 and form == 'bottom':
                section = 'W24x103'
            elif axis in [1, 4] and story == 3 and form == 'top':
                section = 'W24x76'
            elif axis in [2, 3] and story == 3 and form == 'bottom':
                section = 'W24x146'
            elif axis in [2, 3] and story == 3 and form == 'top':
                section = 'W24x84'
            elif axis in [1, 4] and story == 4:
                section = 'W24x76'
            elif axis in [2, 3] and story == 4:
                section = 'W24x84'
        elif type_ == 'panelzone':
            check_input(type_, story, floor, span, axis)
            if axis in [1, 4] and floor in [2, 3]:
                d = 622.3
                t = 13.97
                t1 = 4/16 * 25.4
            elif axis in [2, 3] and floor in [2, 3]:
                d = 627.38
                t = 16.51
                t1 = 15/16 * 25.4
            elif axis in [1, 4] and floor in [4, 5]:
                d = 607.06
                t = 11.176
                t1 = 4/16 * 25.4
            elif axis in [2, 3] and floor in [4, 5]:
                d = 612.14
                t = 11.938
                t1 = 15/16 * 25.4
            section = 0.95 * d * (t + t1)
        else:
            raise ValueError('【Error】构件类型输入错误')
        
    # ------------------ 8层框架 ----------------------------
    elif N == 8:
        ...

    # ------------------ 12层框架 ----------------------------
    elif N == 12:
        ...

    else:
        raise ValueError('【Error】N输入错误')
    
    return section


if __name__ == "__main__":
    section = get_section(4, 'panelzone', floor=3, axis=2)
    print(section)