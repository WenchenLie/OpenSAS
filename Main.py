import time
from MRFcore.MRF import MRF
from MRFcore.QuakeReadPushover import QuakeReadPushover
from MRFcore.DataProcessing import DataProcessing
from MRFcore.FragilityAnalysis import FragilityAnalysis

"""
可分析工况：时程分析、Pushover、IDA

周期备忘：
MRF_4S_AE:       1.421 0.442 0.228
MRF_4S_AE:       1.242 0.406 0.2

在运行任何新模型前:
1 - 确保地震动选择及缩放的相关方法中结构的周期正确
2 - `Output_dir`参数中禁止出现中文路径

OS模型中的单位：N, mm, t
"""

def run():

    notes = """4层3跨钢框架模型，由Dr Elkady设计，采用RBS梁柱连接
    """  # 模型说明
    model = MRF('MRF_4S_AS', N=4, notes=notes, script='tcl')
    model.select_ground_motions([f'th{i}' for i in range(1, 45)], suffix='.th')
    # model.select_ground_motions(['th2'], suffix='.th')
    T1 = 1.242
    # model.scale_ground_motions('data/DBE_AE.txt', method='i', para=(T1, 1), plot=False, SF_code=1.5)  # 只有跑时程需要定义
    model.set_running_parameters(Output_dir='H:/MRF_results/4SMRF_AS', fv_duration=30, display=True, auto_quit=False)
    # model.run_time_history(print_result=True)
    model.run_IDA(T1, 0.1, 0.1, 0.01, max_ana=80, parallel=22, print_result=False)
    # model.run_pushover(print_result=True)
    # QuakeReadPushover('H:/MRF_results/test/4SMRF_AE')


def data_processing():

    time0 = time.time()
    model = DataProcessing(r'H:/MRF_results/4SMRF_AS', gm_suffix='.th')
    model.set_output_dir(r'H:/MRF_results/4SMRF_AS_out', cover=1)
    model.read_results('mode', 'IDR')
    model.read_results('CIDR', 'PFA', 'PFV', 'shear', 'panelZone', 'beamHinge', 'columnHinge', print_result=True)
    # model.read_pushover(H=16300, plot_result=True)
    # model.read_th()  # 只有时程分析工况需要用
    time1 = time.time()
    print('耗时', time1 - time0)


def fragility_analysis():

    # 层间位移角
    Model = FragilityAnalysis(r'H:/MRF_results/4SMRF_AS_out', EDP_type=1)
    Model.calc_IDA(DM_limit=0.1)
    Model.frag_curve(
        Damage_State=[0.005, 0.01, 0.02, 0.04],
        label=['DS-1', 'DS-2', 'DS-3', 'DS-4']
    )
    Model.frag_collapse(IM_MCE=[0.5631186282943467*1.5])
    Model.exceedance_probability(EDP_val=0.1)
    Model.PlotCurves()
    Model.Print_data()
    Model.Save_data(r'H:/MRF_results/4SMRF_AS_out_frag')



if __name__ == "__main__":

    run()
    data_processing()
    fragility_analysis()

    pass



"""
------------------- 模型备注 -----------------------

MRF_4S_AE:            4层3跨空钢框架(Elkady博士设计)，不考虑重力框架抗弯，不考虑组合楼板效应，梁柱采用RBS连接
MRF_4S_AS:            4层3跨空钢框架(Skiadopoulos博士设计)，不考虑重力框架抗弯，不考虑组合楼板效应，梁柱采用fully constrainted连接（非RBS）

---------------------------------------------------
"""

