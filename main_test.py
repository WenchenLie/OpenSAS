import multiprocessing
from MRFcore.MRF import MRF

# 定义一个计算平方的函数
def worker(gm: str):
    notes = """
    """  # 模型说明
    model = MRF('MRF_4S_AE', N=4, notes=notes, script='py')
    # model.select_ground_motions([f'th{i}' for i in range(1, 7)], suffix='.th')
    model.select_ground_motions([gm], suffix='.th') 
    T1 = 1.397
    model.scale_ground_motions('data/DBE_AE.txt', method='i', para=(T1, 1), plot=False, SF_code=1.5)  # 只有跑时程需要定义
    model.set_running_parameters(Output_dir='H:/MRF_results/test/4SMRF_AE', fv_duration=0, display=False, log_name='日志',
                                 auto_quit=True, folder_exists='overwrite', parallel=4)
    model.run_time_history(print_result=False)

def main():
    # 定义一个需要计算的数字列表
    gms = [f'th{i}' for i in range(1, 7)]
    
    # 创建一个进程池，大小为系统CPU核心数
    with multiprocessing.Pool(3) as pool:
        # map 方法类似于内置的 map 函数，但它会自动分配到各个进程
        pool.map(worker, gms)
        

# 确保只在直接运行此脚本时执行主函数
if __name__ == '__main__':
    main()
