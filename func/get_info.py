import re


def get_info(file_name: str):
    """解析摇摆跨构件的文件名，获得单元类型，编号等信息\n
    为保证识别准确性，最大支持层数：20，
    跨数仅支持：96、97、98、99

    Args:
        file_name (str): 文件名(带后缀)

    Return:
        type_ (str): 构件类型(Beam, Column, Link, Truss)
        story (int): 层数(从1开始，如柱、支撑)\n
        floor (int): 层数(从2开始，如梁、Link)\n
        span (int): 跨编号(96-99)\n
        axis (int): 轴编号(96-99)\n
        form (str): 构件的特殊型式，如没有特殊型式，为None\n
        * 柱: 'bottom' - 连接节点以下的柱段\n
              'top' - 连接节点以上的柱段
        * 支撑: '/': 方向为左下-右上的斜撑\n
                '(反斜杠)': 方向为左上-右下的斜撑
    """
    pattern_base = re.compile(r'R_([A-Za-z]+)([0-9]+).out')
    if not re.findall(pattern_base, file_name):
        return  # 所选文件不属于摇摆跨的构件
    type_ = re.fullmatch(pattern_base, file_name).group(1)
    id_ = re.fullmatch(pattern_base, file_name).group(2)
    if type_ not in ['Beam', 'Column', 'Link', 'Truss']:
        raise ValueError(f'【Error】无法匹配"{type_}"类型')

    if type_ == 'Beam':
        pattern = re.compile(r'(50|5)([1-9]|1[0-9]|20|21)(96|97|98|99)00')
        result = re.fullmatch(pattern, id_)
        if result is None:
            raise ValueError(f'【Error】无法匹配{file_name}')
        story = int(result.group(2)) - 1
        floor = int(result.group(2))
        span = int(result.group(3))
        axis = span
        form =  None
    elif type_ == 'Column':
        pattern = re.compile(r'(6|60|600)([1-9]|1[0-9]|20)(96|97|98|99)(00|1|2)')
        result = re.fullmatch(pattern, id_)
        if result is None:
            raise ValueError(f'【Error】无法匹配{file_name}')
        story = int(result.group(2))
        floor = story + 1
        span = int(result.group(3))
        axis = span
        g4 = result.group(4)
        if g4 == '1':
            form = 'bottom'
        elif g4 == '2':
            form = 'top'
        else:
            form = None
    elif type_ == 'Link':
        pattern = re.compile(r'(5|50)([1-9]|1[0-9]|20|21)(96|97|98|99)00')
        result = re.fullmatch(pattern, id_)
        if result is None:
            raise ValueError(f'【Error】无法匹配{file_name}')
        story = int(result.group(2)) - 1
        floor = int(result.group(2))
        span = int(result.group(3))
        axis = span
        form = None
    elif type_ == 'Truss':
        pattern = re.compile(r'74([1-9]|1[0-9]|20)(96|97|98|99)([12])')
        result = re.fullmatch(pattern, id_)
        if result is None:
            raise ValueError(f'【Error】无法匹配{file_name}')
        story = int(result.group(1))
        floor = story + 1
        span = int(result.group(2))
        axis = span
        g3 = result.group(3)
        if g3 == '1':
            form = '/'
        else:
            form = '\\'

    return type_, story, floor, span, axis, form
        



if __name__ == "__main__":

    files = ['R_Beam5039900.out', 'R_Column6003992.out', 'R_Column6049900.out',
             'R_Link5029800.out', 'R_Truss743991.out', 'R_safas.out']

    # for file in files:
    #     get_info(file)
    print(get_info(files[4]))
    # get_info('R_Column60049900.out')