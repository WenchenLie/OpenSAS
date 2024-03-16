import sys
from MRF import MRF
from loguru import logger


"""
可分析工况：时程分析、Pushover、IDA

周期备忘：
4SMRF:    1.242 0.406 0.2

在运行任何新模型前:
1 - 确保地震动选择及缩放的相关方法中结构的周期正确
2 - `Output_dir`参数中禁止出现中文路径

OS模型中的单位：N, mm, t
"""

logger.remove()
logger.add(
    sink=sys.stdout,
    format="<green>{time:YYYY-MM-DD HH:mm:ss}</green> <red>|</red> <level>{level}</level> <red>|</red> <level>{message}</level>",
    level="DEBUG"
)

notes = """
4层空钢框架，不考虑楼板组合效应
根据design summary文件进行设计
一根虚拟柱
Sa0 = 0.1g
Sa_incr = 0.1g
tol = 0.01g
"""  # 模型说明
model = MRF('4SMRF', N=4, notes=notes, logger=logger)
# model.select_ground_motions([f'th{i}' for i in range(1, 45)], suffix='.th')
model.select_ground_motions(['th6'], suffix='.th')
T1 = 1.242
model.scale_ground_motions('模型信息/DBE谱.txt', method='i', para=(T1, 2.0), plot=False)  # 只有跑时程需要定义
model.set_running_parameters(Output_dir='H:/MRF_results/test/4SMRF', fv_duration=30, display=False)
model.run_time_history(print_result=True)
# model.run_IDA(T1, 0.1, 0.1, 0.01, max_ana=80, intensity_measure=1)
# model.run_pushover(print_result=True)



"""
------------------- 模型备注 -----------------------

4SMRF:         4层3跨空钢框架(Skiadopoulos博士设计)，不考虑重力框架抗弯，不考虑组合楼板效应，梁柱采用fully constrainted连接（非RBS）
4SMRF_VSL:     在4SMRF基础上使用Vertical shear links
4SMRF-Elkady:  4层3跨空钢框架(Elakedy博士设计)

---------------------------------------------------
"""

