def get_rocking_section(N: int, type_, story: int=None, floor: int=None, span: int=None, axis: int=None, form: str=None):
    """根据摇摆跨构件所在的层、跨等信息，获得构件属性(A、I、W)

    Args:
        N (int): 结构总层数
        type_ (str): 构件类型(Beam, Column, Link, Truss)
        story (int): 层数(从1开始，如柱、支撑)
        floor (int): 层数(从2开始，如梁，Link)
        span (int): 跨编号
        axis (int): 轴编号
        form (str): 构件特殊形式

    Return:
        str: 截面型号
    """

    if N == 4:
        # 4层结构
        if type_ == 'Beam':
            if 2 <= floor <= 3:
                section = 'W24x76'
            elif 4 <= floor <= 5:
                section = 'W18x60'
            else:
                raise ValueError('【Error】1')
        elif type_ == 'Column':
            section = 'W14x90'
        elif type_ == 'Truss':
            if story == 1:
                section = 'W12x96'
            else:
                section = 'HSS12x8x5/16'
        else:
            raise ValueError(f'【Error】不支持类型"{type_}"')
        
    else:
        pass  # TODO

    return section

