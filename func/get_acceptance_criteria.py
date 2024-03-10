from wsection import WSection
import numpy as np
import func


def get_acceptance_criteria(type_, section):
    E = 206000
    fy = 345
    if type_ == 'beam' or 'column':
        prop = WSection(section)
        bf = prop.bf
        tf = prop.tf
        h = prop.h
        tw = prop.tw
        IMK_para = prop.IMKbeam_modeling(5400, 2700, 2700)
        theta_y = IMK_para['My_P'] / IMK_para['K']
        if type_ == 'beam':
            # if bf/(2*tf) <= 0.3*np.sqrt(E/fy) and h/tw <= 2.45*np.sqrt(E/fy):
            #     c = 0.6
            # elif bf/(2*tf) >= 0.38*np.sqrt(E/fy) or h/tw >= 3.76*np.sqrt(E/fy):
            #     c = 0.2
            # else:
            #     c1 = func.interpolation(0.3*np.sqrt(E/fy), 0.6, 0.38*np.sqrt(E/fy), 0.2, bf/(2*tf))
            #     c2 = func.interpolation(2.45*np.sqrt(E/fy), 0.6, 3.76*np.sqrt(E/fy), 0.2, h/tw)
            #     c = min(c1, c2)
            # IO = 0.25 * c
            ...

        elif type_ == 'column':
            ...

    elif type_ == 'panelzone':
        ...

    else:
        raise ValueError('【Error】type_参数错误')
    

def get_ductility(type_: str, section: str | None, theta: float, floor: int, PgPye: float=None, L_beam: float=None, L_col: float=None) -> float:
    """获得构件延性系数，屈服转角的计算按照asce 41-17

    Args:
        type_ (str): 构件类型, beam, column, panelzone
        section (str | None): 截面名(当为节点域时填None)
        theta (float): 塑性铰或节点域弹簧转角
        floor (int): 几楼
        PgPye (float, optional): 重力荷载下柱的轴力(N)

    Returns:
        float: 延性系数
    """
    E = 206000
    fy = 345
    G = E / (2 * (1 + 0.3))

    if type_ == 'beam' or 'column':
        prop = WSection(section, fy)
        
        if type_ == 'beam':
            if not L_beam:
                raise ValueError('【Error】请指定L_beam参数')
            As = (prop.d - 2*prop.tf) * prop.tw
            yita = 12 * E * prop.Ix / (L_beam**2 * G * As)
            theta_y = prop.My * L_beam * (1 + yita) / (6 * E * prop.Ix)
            miu = theta / theta_y

        elif type_ == 'column':
            if not PgPye:
                raise ValueError('【Error】请指定PgPye参数')
            if not L_col:
                raise ValueError('【Error】请指定L_col参数')
            if PgPye < 0.2:
                Mpce = prop.My * (1 - PgPye / 2)
            else:
                Mpce = prop.My * 9/8 * (1 - PgPye)
            if PgPye <= 0.5:
                tau_b = 1
            else:
                tau_b = 4 * PgPye * (1 - PgPye)
            theta_y = Mpce * L_col * (1 + yita) / (6 * tau_b * E * prop.Ix)
            miu = theta / theta_y

    elif type_ == 'panelzone':
        if not PgPye:
            raise ValueError('【Error】请指定PgPye参数')
        gamma_y = fy / (3**0.5 * G) * (1 - PgPye**2)**0.5
        miu = theta / gamma_y

    else:
        raise ValueError('【Error】type_参数错误')
    
    return miu