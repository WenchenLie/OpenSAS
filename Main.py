from MRFcore.MRF import MRF
from MRFcore.QuakeReadPushover import QuakeReadPushover
from MRFcore.DataProcessing import DataProcessing
from MRFcore.FragilityAnalysis import FragilityAnalysis

"""
可分析工况：时程分析、Pushover、IDA

周期备忘：
MRF_4S_AE:       1.421 0.442 0.228

在运行任何新模型前:
1 - 确保地震动选择及缩放的相关方法中结构的周期正确
2 - `Output_dir`参数中禁止出现中文路径

OS模型中的单位：N, mm, t
"""


if __name__ == "__main__":
    
    notes = """
    """  # 模型说明
    model = MRF('MRF_4S_AE', N=4, notes=notes, script='py')
    model.select_ground_motions([f'th{i}' for i in range(1, 45)], suffix='.th')
    # model.select_ground_motions(['th2'], suffix='.th')
    T1 = 1.421
    # model.scale_ground_motions('data/DBE_AE.txt', method='i', para=(T1, 1), plot=False, SF_code=1.5)  # 只有跑时程需要定义
    model.set_running_parameters(Output_dir='H:/MRF_results/test/4SMRF_AE_parralle_py_test', fv_duration=30, display=True, auto_quit=False)
    # model.run_time_history(print_result=True)
    model.run_IDA(T1, 0.1, 0.1, 0.01, max_ana=80, intensity_measure=1, trace_collapse=True, parallel=22, print_result=False)
    # model.run_pushover(print_result=True)
    # QuakeReadPushover('H:/MRF_results/test/4SMRF_AE')


"""
------------------- 模型备注 -----------------------

MRF_4S_AE:            4层3跨空钢框架(Elkady博士设计)，不考虑重力框架抗弯，不考虑组合楼板效应，梁柱采用RBS连接
MRF_4S_AS:            4层3跨空钢框架(Skiadopoulos博士设计)，不考虑重力框架抗弯，不考虑组合楼板效应，梁柱采用fully constrainted连接（非RBS）

---------------------------------------------------
"""

