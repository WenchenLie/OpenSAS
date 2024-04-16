import time
from MRFcore.MRF import MRF
from MRFcore.QuakeReadPushover import QuakeReadPushover
from MRFcore.QuakePlotHinge import QuakePlotHinge
from MRFcore.DataProcessing import DataProcessing
from MRFcore.FragilityAnalysis import FragilityAnalysis

"""
可分析工况：时程分析、Pushover、IDA

周期备忘：
MRF_4S_AE:          1.421 0.442 0.228
MRF_4S_AS:          1.242 0.406 0.2
6SRCF1_noWall:      1.735 0.562 0.305 (考虑等效刚度)
                    1.08  0.341 0.181 (不考虑等效刚度)
6SRCF1_TMIW:        0.696 0.204 0.095 (考虑等效刚度)
                    0.55  0.175 0.087 (不考虑等效刚度)
STKO_6SRCFnoWall:   1.233 0.392 0.21
STKO_6SRCF_TMIW:    0.615 0.2   0.097
STKO_6SRCF_DMIW:    1.27  0.404 0.215


在运行任何新模型前:
1 - 确保地震动选择及缩放的相关方法中结构的周期正确
2 - `Output_dir`参数中禁止出现中文路径

OS模型中的单位：N, mm, t
"""

def run():

    notes = """6层3跨钢筋混凝土框架-无填充墙，按有填充墙设计，设计时考虑周期折减系数0.7，分析时删去墙部分的质量
    """  # 模型说明
    model = MRF('STKO_6SRCF_TMIW', N=6, notes=notes, script='tcl')
    # model.select_ground_motions([f'th{i}' for i in range(1, 45)], suffix='.th')
    # model.select_ground_motions(['th2'], suffix='.th')
    T1 = 0.55
    # model.scale_ground_motions('data/DBE_AE.txt', method='i', para=(T1, 1), plot=True, SF_code=1.5)  # 只有跑时程需要定义
    model.set_running_parameters(Output_dir='H:/RCF_results/test/STKO_6SRCF', fv_duration=0, display=True, auto_quit=True)
    # model.run_time_history(print_result=True)
    # model.run_IDA(T1, 0.2, 0.2, 0.02, max_ana=80, parallel=22, print_result=False)
    model.run_pushover(0.6, print_result=True)
    QuakeReadPushover('H:/RCF_results/test/STKO_6SRCF')


def data_processing():

    time0 = time.time()
    model = DataProcessing(r'H:/RCF_results/6SRCF1_TMIW', gm_suffix='.th')
    model.set_output_dir(r'H:/RCF_results/6SRCF1_TMIW_out', cover=1)
    model.read_results('mode', 'IDR')
    # model.read_results('CIDR', 'PFA', 'PFV', 'shear', 'panelZone', 'beamHinge', 'columnHinge', print_result=True)
    model.read_results('CIDR', 'PFA', 'PFV', 'shear', print_result=True)
    # model.read_pushover(H=24300, plot_result=True)
    # model.read_th()  # 只有时程分析工况需要用
    time1 = time.time()
    print('耗时', time1 - time0)


def fragility_analysis():

    # 层间位移角
    Model = FragilityAnalysis(r'H:/RCF_results/6SRCF1_TMIW_out', EDP_type=1)
    Model.calc_IDA(DM_limit=0.1)
    Model.frag_curve(
        Damage_State=[0.005, 0.01, 0.02, 0.04],
        label=['DS-1', 'DS-2', 'DS-3', 'DS-4']
    )
    Model.frag_collapse(IM_MCE=[0.5631186282943467*1.5])
    Model.exceedance_probability(EDP_val=0.1)
    Model.PlotCurves()
    Model.Print_data()
    Model.Save_data(r'H:/RCF_results/6SRCF1_TMIW_out_frag')



if __name__ == "__main__":

    run()
    # QuakeReadPushover('H:/RCF_results/6SRCFnoWall_pushover')
    # QuakePlotHinge(r'H:\RCF_results\6SRCFnoWall_pushover\Pushover', 'c', floor=2, axis=1, position='B')
    # data_processing()
    # fragility_analysis()

    pass



"""
------------------- 模型备注 -----------------------

MRF_4S_AE:            4层3跨空钢框架(Elkady博士设计)，不考虑重力框架抗弯，不考虑组合楼板效应，梁柱采用RBS连接
MRF_4S_AS:            4层3跨空钢框架(Skiadopoulos博士设计)，不考虑重力框架抗弯，不考虑组合楼板效应，梁柱采用fully constrainted连接（非RBS）

---------------------------------------------------
"""

