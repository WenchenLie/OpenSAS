# 基于OpenSees的结构抗震分析(pushover、时程分析、IDA)辅助程序
## 1. 简介
该程序可以基于建筑结构的OpenSees脚本进行抗震分析，支持共三种分析类型：pushover分析，时程分析和IDA，且均支持tcl和openseespy脚本。在进行多次的计算分析时，程序的主要作用为修改OpenSees脚本的文本，然后调用OpenSees求解器（根据脚本类型通过命令行openseespy第三方库调用），在分析完成后还可进行数据处理。此外，在进行多条地震动作用下的时程分析或IDA计算时，程序支持多进程并行计算，以加快计算进度。
## 2. 准备
### 2.1 项目结构
项目文件夹中入口文件为`Main.py`，`MRFcore`和`func`文件夹包括计算前、后处理相关的模块，`GMs`为存放地震动加速度时程数据的文件夹，`models`为待分析的OpenSees脚本存放的文件夹，`data`为存放反应谱数据或其他所需数据的文件夹，`OS_terminal`为存放OpenSees求解终端的文件夹，`subroutines`存放计算过程中的OpenSees调用的分析模块或函数。在计算过程中，可能产生`temp`文件夹用于生成临时文件，此外生成的计算日志存放在`log`文件夹。
### 2.2 地震动
地震动加速度时程数据存放在`GMs`文件夹，包括`GM_info.txt`和其他加速度时程文本文档，其中各条地震动加速度时程以一列存放（如th1.th），`GM_info.txt`包括两列数据，分别为地震动名称和对应的步长，应保证`GM_info.txt`中包括所有所需地震动的步长信息。
### 2.3 反应谱
若涉及需要导入目标反应谱的分析步骤（如基于目标谱的地震动缩放），则需把反应谱文档存放在`data`文件夹，以两列数据存放，分别为目标谱的周期和加速度谱值。
### 2.4 OpenSees模型脚本
待分析的OpenSees模型脚本存放在`models`中，可存放tcl脚本或基于openseespy的python脚本，程序在开始计算时，会读取脚本文本进行相应的修改，以控制每次分析时的所需参数（如地震动信息，相关求解设置等）。  
#### 2.4.1 tcl脚本
程序在修改tcl脚本文本时，通过特定的标识符来进行正则匹配，标识符为"$$$"，带有标识符的变量可以通过本程序定义。  
注：（1）带有标识符的变量应慎重修改，修改后应保证格式无误，如`set GMdt 0.01;  # $$$`，可修改为`set GMdt 0.02;  # $$$`，其余的空格和$字符不要动。对于钢框架结构通常建议使用MRFHelper生成结构OpenSees分析模型，该方法可自动生成正确标识符。
#### 2.4.2 openseespy脚本
openseespy分析脚本主要包括一个带有特定参数的名为`run_openseespy`的函数，主程序会直接调用该函数并传入不同的参数来进行不同工况的计算。
## 3. 计算
首先从`MRFcore`中导入`MRF`类并实例化为变量`model`。
```
from MRFcore.MRF import MRF
model = MRF(model_name: str, N: int, script: Literal['tcl', 'py']='tcl', notes='')
```
* model_name: 模型名称，应与tcl模型的文件名一致
* N: 结构层数
* notes: 模型的相关描述或备忘，默认为''
* script: 待分析的OpenSees的脚本的类型，'tcl'或'py'  
### 3.1 选择与缩放地震动
实例化模型后，使用方法`select_ground_motions`进行地震动的选择（若只进行pushover，可不进行这步）。
```
model.select_ground_motions(GMs: list, suffix: str='.txt')
```
* GMs (list): 一个包含所有地震动文件名(不包括后缀)的列表
* suffix (str, optional): 地震动文件后缀，默认为'.txt'  
选择地震动后，需按照相应方法进行缩放，（进行pushover分析或IDA时无需进行），
```
model.scale_ground_motions(
    path_spec_code: str,
    method: str,
    para: None | float | tuple | str,
    SF_code: float=1.0,
    save_SF=False,
    plot=True,
    save_unscaled_spec=False,
    save_scaled_spec=False)
```
* path_spec_code: 目标谱的文件路径，文件应包含两列数据，为周期和加速度谱值
* method: 地震动的缩放方法，为'a'-'g'：  
'a' - 按Sa(T=0)匹配反应谱, pare=None
'b' - 按Sa(T=Ta)匹配反应谱, para=Ta  
'c' - 按Sa(Ta) ~ Sa(Tb)匹配反应谱, para=(Ta, Tb)  
'd' - 指定PGA, para=PGA  
'e' - 不缩放  
'f' - 指定相同缩放系数, para=SF  
'g' - 按文件指定, para=path: str (如'temp/GM_SFs.txt')，文件包含一列n行个数据  
'h' - 按Sa,avg(T1, T2)匹配反应谱，即T1~T2间的加速度谱值的几何平均数，para=(T1, T2)  
'i' - 指定Sa(Ta), para=(Ta, Sa)  
'j' - 指定Sa,avg(Ta~Tb), para=(Ta, Tb, Sa,avg), 分别代表n条地震动的缩放系数
* para: 地震动缩放所需参数，与method的取值有关
* SF_code: 读取目标谱时将目标谱乘以一个缩放系数，默认为1
* save: 是否保存缩放后的缩放系数(将保存至temp文件夹，可以作为method取'g'时para参数对应的文件路径，默认为False)
* plot: 是否绘制缩放后地震动反应谱与目标谱的对比图，默认为True
* save_unscaled_spec: 是否保存未缩放地震动反应谱，默认False
* save_scaled_spec: 是否保存缩放后地震动反应谱，默认False  
### 3.2 求解参数设置
在开始进行分析之前，还需对相关的求解参数进行设置。
```
set_running_parameters(
            Output_dir: str | Path=None,
            OS_terminal: str='OpenSees351',
            fv_duration=0.0,
            display=True,
            mpco=False,
            log_name='日志',
            maxRunTime: float=600,
            auto_quit: bool=False,
            folder_exists: Literal['ask', 'overwrite', 'delete']='ask')
```
* Output_dir: 结果文件的存放主文件夹，为None时则为当前工作路径  
* OS_terminal: OpenSees终端的版本（不带后缀的文件名，默认为OpenSees351），可执行终端文件都放在OS_terminal文件夹(使用opensespy类型脚本时可忽略)  
* fv_duration: 时程分析时的自由振动时长，默认为0(pushover分析可忽略)  
* display: 是否显示运行时结构的实时变形图(IDA计算或采用openseespy时不支持)  
* mpco: 是否创建mpco文件，用于被STKO读取后处理(采用openseespy时不支持)  
* log_name: 日志文件名  
* maxRunTime: 最大允许运行时间(s)，默认600s  
* auto_quit: 计算完成时是否自动关闭监控窗口，默认False  
* folder_exists: 如果输出文件夹`Output_dir`存在，如何处理。ask-询问，overwrite-覆盖，delete-删除

完成求解参数设置后，根据需要运行的工况类型（pushover，时程分析，IDA），选择3.3~3.5中的一节进行运行。
### 3.3 时程分析
通过调用`run_time_history`方法进行多条地震动作用下的时程分析。
```
run_time_history(
    print_result=False,
    collapse_limit: float=0.1
    parallel: int=0)
```
* print_result: 是否打印OpenSees输出的信息，默认为False
* collapse_limit: 倒塌判定极限位移角，默认0.1
* parallel: 多进程并行计算，默认为0，代表不开启并行，为其他数时则代表最大进程数  
注：在使用并行计算时，无法实时显示结构变形图。
### 3.4 IDA（增量动力分析）
通过调用`run_IDA`方法进行IDA分析。IDA可指定两种地震动强度指标，分别为Sa(T1)和Sa,avg(T1~T2)，此外当`trace_collapse`为`True`时，程序将不断迭代以搜索结构的倒塌点，直至满足收敛容差`tol`。结构倒塌的判定准则为：(1)结构某层的层间位移角超过`collapse_limit`，(2)结构发生动力失稳而侧向倒塌。建议在进行IDA计算时开启并行计算，参数`parallel`可取为cpu核心数，可极大提高计算效率。
```
run_IDA(
    T0: float,
    Sa0: float,
    Sa_incr:
    float, tol:
    float,
    max_ana=30,
    test=False,
    intensity_measure: Literal[1, 2]=1,
    T_range: tuple=None,
    print_result=False,
    trace_collapse: bool=True,
    parallel: int=0):
```
* T0: 一阶周期  
* Sa0: 初始强度值  
* Sa_incr: 强度增量  
* tol: 倒塌点收敛容差  
* collapse_limit: 倒塌判定极限位移角    
* max_ana: 每个地震动最大分析次数，默认30  
* test: 程序调试用，不用管  
* intensity_measure: 地震动强度指标  
1: Sa(T0), T0为一阶周期  
2: Sa,avg, 给定周期范围内的简单几何平方根  
* T_range: 周期范围，默认None，当`intensity_measure`为2时生效  
* print_result: 是否打印opensees终端输出的结果，默认不打印  
* trace_collapse: 是否追踪倒塌，默认True（若False则不动态调整地震动强度以搜寻倒塌点）  
* parallel: 多进程并行计算，默认为0，代表不开启并行，为其他数时则代表最大进程数  
### 3.5 pushover分析
通过调用`run_pushover`方法进行pushover分析，侧向分布力模式基于楼层的第一振型（各层的侧向力等于振型位移与对应楼层质量的乘积）。
```
run_pushover(maxRoofDrift: float=0.1, print_result: bool=False)
```
* maxRoofDrift: 目标最大层间位移角
* print_result: 是否打印OpenSees输出的内容，默认为False
## 4. 后处理
### 4.1 数据处理
在进行大量时程分析计算后，所有数据会储存在一个主文件夹中（3.2节中的`Output_dir`），主文件夹又包括多个子文件夹，每个子文件夹代表每次时程分析得到的数据。对于这些计算得到的数据，进行初步处理以计算各项结构性能指标的最值。首先从`MRFcore`导入`DataProcessing`类并实例化。
```
from MRFcore.DataProcessing import DataProcessing
model = DataProcessing(
    root: str | Path,
    max_mode: int=None,
    gm_file: str | Path='F:/MRF/GMs',
    gm_suffix='.txt')
```
* root: 要读取的主文件夹的路径
* check: 是否检查数据是否完整，默认`True`
* max_mode: 读取的最大模态数，默认`None`（对于大型结构一般不用读取所有模态，
为`None`时读取的模态数等于结构层数）
* gm_suffix: 地震动文件的后缀，默认'.txt'  

设置输出文件夹路径，以保存处理后的数据。
```
set_output_dir(output_dir: str | Path, cover: int=1)
```
* output_dir: 输出目录的绝对路径  
* cover: 当`output_dir`存在时的操作  
1 - 覆盖  
2 - 删除原文件夹  
3 - 退出

使用`read_results`方法，读取各项结构性能参数的时程结果，并统计其最值。其中args参数可输入多个，以读取振型及模态、最大及残余层间位移角、楼层及基底剪力、加速度、速度、梁铰、柱铰、节点域转动弹簧。
```
read_results(*args: str, print_result=True, read_other=True)
```
* args: 要读取的结果类型，包括：  
'mode' - 振型、模态  
'IDR' - 最大层间位移角，残余层间位移角  
'shear' - 楼层剪力、基底剪力时程  
'PFA' - 楼层加速度包络，屋顶加速度时程  
'PFV' - 楼层速度包络， 屋顶速度时程  
'beamHinge' - 梁铰变形  
'columnHinge' - 柱铰变形  
'panelZone' - 节点域变形
* print_result: 是否在读取过程中打印结果  
* read_other: 是否读取其他项，默认True

当分析工况为时程分析或pushover分析时（即不是IDA），可以调用以下方法，统计时程分析结果或pushover分析结果。
```
read_th()
```
或
```
read_pushover(H: float, FDR_step=[0.01*i for i in range(1, 11)], plot_result=True)
```
* H: 结构总高度
* FDR_step: 不同级别的屋顶位移角，用于计算并绘制不同屋顶位移角下结构的归一化层位移
* plot_result: 是否绘制曲线（默认True）
### 4.2 易损性分析
当计算工况为IDA时，可调用`MRFcore`中的`FragilityAnalysis`类对IDA结果进行易损性分析。
```
from MRFcore.FragilityAnalysis import FragilityAnalysis
model = FragilityAnalysis(root: str | Path, EDP_type: int)
```
* root: 待读取数据的文件夹的路径(即4.1节中输出的文件夹路)  
* EDP_type: 工程需求参数类型  
1 - 最大层间位移角  
2 - 残余层间位移角  
3 - 楼层加速度包络  
4 - 屋顶最大加速度  
5 - 楼层速度包络  

首先调用`calc_IDA`方法计算IDA曲线。
```
calc_IDA(DM_limit: float=None, slope_limit: float=None)
```
* DM_limit: 损伤指标的最大限值，如果计算得到的DM值大于该值，则不统计，
若不指定，则默认不统计倒塌点(当EDP采用层间位移角时，可设为0.1或0.15)  
* slope_limit: 如果IDA曲线某点的斜率与初始斜率之比小于`slope_limit`，
则删除该点及之后的数据

注：仅DM_limit为界限计算IDA曲线，如果有的点的DM值超过DM_limit，
则取为该点与上一个点之间的直线与竖线DM=DM_limit的交点，并忽略后续的所有点

调用`frag_curve`方法对概率需求模型进行拟合。
```
frag_curve(Damage_State: list, label: list, betaDC=0.4):
```
* Damage_State: 不同损伤状态对应的EDP
* label: 不同损伤状态对应的描述(如'DS-1')
* IM1: DM-IM曲线的横坐标范围起始值
* IM2: DM-IM曲线的横坐标范围终止值
* betaDC: sqrt(beta_D^2 + beta_C^2)的值(默认0.4)

调用`frag_collapse`方法计算倒塌易损性曲线。
```
frag_collapse(IM_MCE: list)
```
* IM_MCE: MCE地震下结构一阶周期对应的规范谱值Sa(T1)，用于计算倒塌储备系统MCR

调用`exceedance_probability`方法计算EDP关于某值的超越概率
```
exceedance_probability(EDP_val: float):
```
* EDP_val: 给定一个EDP值(EDP_val)，求其超越概率

最后，依次调用`PlotCurves()`、`Print_data()`和`Save_data`方法，绘制曲线，输出相关结果，并保存数据
```
PlotCurves(plot_IDA_idx=None)
Print_data()
Save_data(output_path: str | Path)
```
* plot_IDA_idx: 序号高亮显示的IDA曲线的序号(从0开始)
* output_path: 将易损性计算结果保存指定文件夹路径
