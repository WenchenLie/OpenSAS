from __future__ import annotations
from typing import TYPE_CHECKING
if TYPE_CHECKING:
    from .MRF import MRF
import os
import re
import time
import shutil
import subprocess
import numpy as np
from pathlib import Path
from PyQt5.QtCore import QThread, pyqtSignal, Qt
from PyQt5.QtWidgets import QApplication, QMessageBox, QDialog
from ui.Win_running import Ui_Win_running


"""
时程分析、增量动力分析、Pushover分析监控窗口
作者：列文琛
更新：2024-03-05
更新：2024-04-07，优化代码
"""

class MyWin(QDialog):

    def __init__(self, main: MRF, running_case: str, IDA_para: tuple, print_result: bool, concurrency: int=None):
        """IDA分析

        Args:
            main (MRF): MRF类\n
            running_case (str): 运行工况，'IDA', 'th'或'pushover'\n
            IDA_para (tuple): IDA参数\n
            * `T0`: 一阶周期
            * `RSA`: 加速度谱
            * `Sa0`: 初始强度
            * `Sa_incr`: 强度增量
            * `tol`: 倒塌点收敛容差
            * `max_ana`: 每条地震动最大计算次数
            * `test`: 程序调试用
            * `intensity_measure`: 地震动缩放方法
                * 1 - Sa(T)
                * 2 - Sa,avg 
            * `T_range`: 当`intensity_measure`为2时，给定的周期范围\n
            print_result (bool): 是否打印结果\n
            concurrency (int): 并发运行的数量
        """
        super().__init__()
        self.ui = Ui_Win_running()
        self.main = main
        self.running_case = running_case  # "th" 或 "IDA"
        self.warning = 0  # 是否有警告信息
        self.current_gm = None
        if IDA_para:
            self.T0, self.RSA, self.Sa0, self.Sa_incr, self.tol, self.max_ana, self.test, self.intensity_measure, self.T_range = IDA_para
        self.print_result = print_result  # 是否输出运行过程中的消息
        self.concurrency = concurrency
        self.ui.setupUi(self)
        self.init_ui()
        self.run()

    def init_ui(self):
        self.setWindowFlags(Qt.WindowMinMaxButtonsHint)
        if self.running_case == 'th':
            self.ui.label_3.setText('正在运行：时程分析')
            self.ui.label_19.setEnabled(False)
            self.ui.label_20.setEnabled(False)
            self.ui.label_9.setText('（仅IDA适用）')
            self.ui.label_9.setEnabled(False)
            self.add_log('运行工况：时程分析\n')
        elif self.running_case == 'IDA':
            self.ui.label_3.setText('正在运行：IDA')
            self.ui.label_20.setText('')
            self.add_log('运行工况：IDA\n')
        elif self.running_case == 'pushover':
            self.ui.label_3.setText('正在运行：pushover')
            self.add_log('运行工况：Pushover分析\n')
        else:
            raise ValueError('【Error】参数 running_case 错误')
        self.add_log(f'总地震动数量：{self.main.GM_N}\n')
        self.add_log(f'输出文件夹：{self.main.Output_dir}\n')
        self.time_project_begin = time.time()
        time_project_begin_struct = time.strftime("%Y/%m/%d\n%H:%M:%S", time.localtime(self.time_project_begin))
        self.add_log('开始时间：' + time_project_begin_struct.replace('\n', ' ') + '\n')
        if self.running_case == 'IDA':
            self.add_log(f'初始强度：{self.Sa0}g\n')
            self.add_log(f'强度增量：{self.Sa_incr}g\n')
            if self.main.trace_collapse:
                self.add_log(f'倒塌点收敛强度容差：{self.tol}g\n')
            else:
                self.add_log(f'倒塌点收敛强度容差：不追踪倒塌点\n')
            dict_ = {1: 'Sa(T)', 2: 'Sa,avg'}
            self.add_log(f'地震动强度指标：{dict_[self.intensity_measure]}\n')
        self.add_log('\n')
        self.ui.label_2.setText(time_project_begin_struct)  # 项目开始时间
        self.model: str = self.main.model_name
        self.ui.label_5.setText(self.model)  # 模型名称
        self.fv_duration: float = self.main.fv_duration
        if self.running_case in ['IDA', 'th']:
            self.ui.label_17.setText(f'{self.fv_duration}s')  # 自由振动时长
        elif self.running_case == 'pushover':
            self.ui.label_17.setText('')
        self.ui.pushButton_2.clicked.connect(self.copy_current_tcl_file)
        self.thread_run = None
        self.ui.pushButton.clicked.connect(self.kill)
        self.ui.pushButton_3.clicked.connect(lambda x: self.quit(self.current_gm))

    def set_ui_gm_info(self, tuple_: tuple):
        gm_name, intensity, duration, dt, NPTS = tuple_
        self.ui.label_7.setText(gm_name)  # 当前地震动
        self.ui.label_9.setText(intensity)  # 地震动强度
        self.ui.label_13.setText(str(duration) + 's')  # 持时
        self.ui.label_11.setText(str(dt) + 's')  # 步长
        self.ui.label_15.setText(str(NPTS))  # 步数

    def set_ui_progrsssBar(self, tuple_: tuple):
        text, val = tuple_
        self.ui.label_18.setText(text)
        self.ui.progressBar.setValue(val)

    def finished(self, state):
        # state: 1-顺利完成计算，2-中断
        time_project_end = time.time()
        time_project_end_struct = time.strftime("%Y/%m/%d %H:%M:%S", time.localtime(time_project_end))
        time_cost = time_project_end - self.time_project_begin
        self.add_log(f'\n分析完成：{time_project_end_struct}\n')
        self.add_log(f'总耗时：{int(time_cost)}s\n')
        with open(self.main.dir_log / f'【{self.running_case.upper()}】{time.strftime("%Y-%m-%d_%H-%M-%S", time.localtime(time_project_end))}.log', 'w') as f:
            text = self.ui.textBrowser.toPlainText()
            f.write(text)
        with open(self.main.Output_dir / f'{self.main.log_name}.log', 'w') as f:
            text = self.ui.textBrowser.toPlainText()
            f.write(text)
        if self.warning == 1:
            with open(self.main.dir_log / f'【warning】{time.strftime("%Y-%m-%d_%H-%M-%S", time.localtime(time_project_end))}.log', 'w') as f:
                text = self.ui.textBrowser_2.toPlainText()
                f.write(text)
            with open(self.main.Output_dir / '警告.log', 'w') as f:
                text = self.ui.textBrowser_2.toPlainText()
                f.write(text)
        if state == 1:
            self.ui.label_18.setText('计算完成！')
            self.ui.progressBar.setValue(100)
        self.ui.pushButton_3.setEnabled(True)
        self.main.logger.success('所有分析已完成')
        if self.main.auto_quit:
            self.accept()

    def run(self):
        self.thread_run = WorkerThread(self.main, self)
        self.thread_run.signal_set_ui.connect(self.set_ui_gm_info)
        self.thread_run.signal_set_progressBar.connect(self.set_ui_progrsssBar)
        self.thread_run.signal_finished.connect(self.finished)
        self.thread_run.signal_add_log.connect(self.add_log)
        self.thread_run.signal_add_warning.connect(self.add_warinng)
        self.thread_run.start()

    def copy_current_tcl_file(self):
        with open(self.main.dir_temp / f'temp_running_{self.main.model_name}_{self.current_gm}.tcl', 'r') as f:
            text = f.read()
        clipboard = QApplication.clipboard()
        clipboard.setText(text)
        self.add_log('已复制tcl代码\n')
        QMessageBox.information(self, '提示', '已复制至剪切板。')

    def kill(self):
        if self.thread_run:
            if QMessageBox.question(self, '警告', '是否中断计算？\n（在计算完该地震动后）') == QMessageBox.Yes:
                self.thread_run.is_kill = 1
                self.add_log('在计算完该地震动后将中断计算!\n')

    def add_log(self, text_add):
        text = self.ui.textBrowser.toPlainText()
        text += text_add
        self.ui.textBrowser.setText(text)
        self.ui.textBrowser.verticalScrollBar().setValue(self.ui.textBrowser.verticalScrollBar().maximum())

    def add_warinng(self, text_add):
        self.ui.tabWidget.setTabText(1, '【警告】')
        text = self.ui.textBrowser_2.toPlainText()
        text += text_add
        self.ui.textBrowser_2.setText(text)
        self.ui.textBrowser_2.verticalScrollBar().setValue(self.ui.textBrowser_2.verticalScrollBar().maximum())
        self.warning = 1

    def quit(self, current_gm):
        # os.remove(f'{self.main.cwd}/temp_running_{self.main.model_name}_{current_gm}.tcl')
        pass


class WorkerThread(QThread):
    """opensees求解线程
    """

    signal_set_ui = pyqtSignal(tuple)  # 运行过程中显示dt，NPTS等
    signal_set_progressBar = pyqtSignal(tuple)  # 运行过程中设置进度条
    signal_finished = pyqtSignal(int)  # 运行完成
    signal_add_log = pyqtSignal(str)  # 增加日志内容
    signal_add_warning = pyqtSignal(str)  # 增加警告内容

    def __init__(self, main: MRF, mainWin: MyWin):
        super().__init__()
        self.main = main
        self.mainWin = mainWin
        self.model_name = self.main.model_name
        self.OS_path: str = main.OS_path
        self.is_kill = 0

    def modify_tcl(self, Output_dir: Path, gm_name: str, dt: str | float,
                   NPTS: int | float, duration: float | str,
                   fv_duration: float | str, SF: float | str, num: int=None):
        """采用正则表达式修改tcl文件

        Args:
            Output_dir (Path): 输出文件夹路径
            gm_name (str): 地震动名
            dt (str | float): 步长
            NPTS (int | float): 步数
            duration (float | str): 持时
            fv_duration (float | str): 自由振动时长
            SF (float | str): 缩放系数
            num (int, optional): 当前地震动的序号
        """

        with open(self.main.dir_model / f'{self.main.model_name}.tcl', 'r') as f:
            text = f.read()
        pattern = re.compile(r'(set MaxRunTime )[0-9.]+(;  # \$\$\$)')
        self.find_pattern(pattern, text)
        text = pattern.sub(r'\g<1>' + str(float(self.main.maxRunTime)) + r'\g<2>', text) 
        pattern1 = re.compile(r'(set EQ )[01](;  # \$\$\$)')
        pattern2 = re.compile(r'(set PO )[01](;  # \$\$\$)')
        self.find_pattern(pattern1, text)
        self.find_pattern(pattern2, text)
        if self.mainWin.running_case in ['th', 'IDA']:
            text = pattern1.sub(r'\g<1>' + '1' + r'\g<2>', text)
            text = pattern2.sub(r'\g<1>' + '0' + r'\g<2>', text)
        elif self.mainWin.running_case == 'pushover':
            text = pattern1.sub(r'\g<1>' + '0' + r'\g<2>', text)
            text = pattern2.sub(r'\g<1>' + '1' + r'\g<2>', text)
        else:
            self.main.logger.warning('无法进行正则匹配\n(set  EQ )')
        pattern = re.compile(r'(set MainFolder ").+(";  # \$\$\$)')
        self.find_pattern(pattern, text)
        text = pattern.sub(r'\g<1>' + Output_dir.absolute().as_posix() + r'\g<2>', text)
        pattern = re.compile(r'(set GMname ").+(";  # \$\$\$)')
        self.find_pattern(pattern, text)
        text = pattern.sub(r'\g<1>' + gm_name + r'\g<2>', text)
        pattern = re.compile(r'(set SubFolder ").+(";  # \$\$\$)')
        self.find_pattern(pattern, text)
        if num:
            text = pattern.sub(r'\g<1>' + f'{gm_name}_{num}' + r'\g<2>', text)
        else:
            text = pattern.sub(r'\g<1>' + gm_name + r'\g<2>', text)
        pattern = re.compile(r'(set GMdt )[0-9.]+(;  # \$\$\$)')
        self.find_pattern(pattern, text)
        text = pattern.sub(r'\g<1>' + str(dt) + r'\g<2>', text)
        pattern = re.compile(r'(set GMpoints )\d+(;  # \$\$\$)')
        self.find_pattern(pattern, text)
        text = pattern.sub(r'\g<1>' + str(NPTS) + r'\g<2>', text)
        pattern = re.compile(r'(set GMduration )[0-9.]+(;  # \$\$\$)')
        self.find_pattern(pattern, text)
        text = pattern.sub(r'\g<1>' + str(duration) + r'\g<2>', text)
        pattern = re.compile(r'(set FVduration )[0-9.]+(;  # \$\$\$)')
        self.find_pattern(pattern, text)
        text = pattern.sub(r'\g<1>' + str(fv_duration) + r'\g<2>', text)
        pattern = re.compile(r'(set EqSF )[0-9.]+(;  # \$\$\$)')
        self.find_pattern(pattern, text)
        text = pattern.sub(r'\g<1>' + str(SF) + r'\g<2>', text)
        pattern = re.compile(r'(set GMFile ").+(";  # \$\$\$)')
        self.find_pattern(pattern, text)
        text = pattern.sub(r'\g<1>' + self.main.dir_gm.as_posix() + f'/$GMname{self.main.suffix}' + r'\g<2>', text)
        pattern = re.compile(r'(set subroutines ").+(";  # \$\$\$)')
        self.find_pattern(pattern, text)
        text = pattern.sub(r'\g<1>' + self.main.dir_subroutines.as_posix() + r'\g<2>', text)
        pattern = re.compile(r'(set temp ").+(";  # \$\$\$)')
        self.find_pattern(pattern, text)
        text = pattern.sub(r'\g<1>' + self.main.dir_temp.as_posix() + r'\g<2>', text)
        pattern = re.compile(r'set ShowAnimation [01];  # \$\$\$')
        self.find_pattern(pattern, text)
        if not self.main.display:
            text = pattern.sub(r'set ShowAnimation 0;  # $$$', text)
        else:
            text = pattern.sub(r'set ShowAnimation 1;  # $$$', text)
        pattern = re.compile(r'set MPCO [01];  # \$\$\$')
        self.find_pattern(pattern, text)
        if self.main.mpco:
            text = pattern.sub(r'set MPCO 1;  # $$$', text)
        else:
            text = pattern.sub(r'set MPCO 0;  # $$$', text)
        with open(self.main.dir_temp / f'temp_running_{self.main.model_name}_{gm_name}.tcl', 'w') as f:
            f.write(text)

    @staticmethod
    def find_pattern(pattern: re.Pattern, text: str):
        """
        如果找不到匹配值，或找到多个匹配值，则报错，
        确保有且只有一种匹配模式
        """
        res = re.findall(pattern, text)
        if len(res) == 0:
            raise ValueError(f'无法匹配: {pattern}')
        if len(res) > 1:
            raise ValueError(f'找到{len(res)}种匹配模式: {pattern}')


    def run(self):
        if self.mainWin.running_case == 'th':
            self.run_th()
        elif self.mainWin.running_case == 'IDA':
            self.run_IDA()
        elif self.mainWin.running_case == 'pushover':
            self.run_pushover()

    def run_th(self):
        for idx in range(self.main.GM_N):
            if self.is_kill == 1:
                self.signal_finished.emit(2)
                break
            self.main.logger.info(f'正在计算第{idx+1}条地震动 ({idx+1}/{self.main.GM_N})')
            gm_name: str = self.main.GM_names[idx]
            self.mainWin.current_gm = gm_name
            dt: float = self.main.GM_dts[idx]
            NPTS: int = self.main.GM_NPTS[idx]
            duration: float = self.main.GM_durations[idx]
            fv_duration: float = self.main.fv_duration
            SF: float = self.main.GM_SF[idx]
            self.signal_set_ui.emit((gm_name, '（仅IDA适用）', duration, dt, NPTS))
            self.signal_set_progressBar.emit((f'正在计算地震动：{idx+1}/{self.main.GM_N}', int(idx / self.main.GM_N * 100)))
            time_gm_start = time.time()
            self.signal_add_log.emit(f'开始：{time.strftime("%Y/%m/%d %H:%M:%S", time.localtime(time_gm_start))}\n')
            self.signal_add_log.emit(f'地震动：{gm_name}\n')
            self.signal_add_log.emit(f'步长：{dt}s\n')
            self.signal_add_log.emit(f'步数：{NPTS}\n')
            self.signal_add_log.emit(f'持时：{duration}s\n')
            self.signal_add_log.emit(f'自由振动时间：{fv_duration}s\n')
            self.signal_add_log.emit(f'缩放系数：{SF:.3f}\n')
            self.modify_tcl(self.main.Output_dir, gm_name, dt, NPTS, duration, fv_duration, SF)
            cmd = f'"{self.OS_path}" "{self.main.dir_temp}/temp_running_{self.main.model_name}_{gm_name}.tcl"'
            # 运行分析
            if self.mainWin.print_result:
                subprocess.call(cmd)
            else:
                subprocess.call(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            # time.sleep(2)  # 模拟耗时工作
            if os.path.exists(self.main.dir_temp / f'{gm_name}_CollapseState.txt'):
                collapsed = 1
                self.signal_add_log.emit(f'倒塌：是\n')
                os.remove(self.main.dir_temp / f'{gm_name}_CollapseState.txt')
            else:
                collapsed = 0
                self.signal_add_log.emit(f'倒塌：否\n')
            if not os.path.exists(self.main.Output_dir / gm_name):
                os.makedirs(self.main.Output_dir / gm_name)
            Sa = None
            if self.main.method == 'd':
                Sa = self.main.th_para  # 指定PGA
            elif self.main.method == 'i':
                Sa = self.main.th_para[1]  # 指定Sa(Ta)
            elif self.main.method == 'j':
                Sa = self.main.th_para[2]  # 指定Sa,avg
            if Sa:
                np.savetxt(self.main.Output_dir / gm_name / 'Sa.dat', np.array([Sa]))
            with open(self.main.Output_dir / gm_name / 'isCollapsed.dat', 'w') as f:
                f.write(str(collapsed))
            # os.remove(self.main.dir_temp / f'temp_running_{self.main.model_name}_{self.mainWin.current_gm}.tcl')  # TODO
            time_gm_end = time.time()
            time_cost = time_gm_end - time_gm_start
            self.signal_add_log.emit(f'结束：{time.strftime("%Y/%m/%d %H:%M:%S", time.localtime(time_gm_end))}\n')
            self.signal_add_log.emit(f'该地震动计算耗时：{round(time_cost, 2)}s\n\n')
        else:
            self.signal_finished.emit(1)


    def run_IDA(self):
        Sa0, Sa_incr, tol, max_ana = self.mainWin.Sa0, self.mainWin.Sa_incr, self.mainWin.tol, self.mainWin.max_ana
        all_break = 0
        for idx in range(self.main.GM_N):
            if all_break == 1:
                self.signal_finished.emit(2)
                break
            self.main.logger.info(f'正在计算第{idx+1}条地震动 ({idx+1}/{self.main.GM_N})')
            gm_name: str = self.main.GM_names[idx]
            self.mainWin.current_gm = gm_name
            dt: float = self.main.GM_dts[idx]
            NPTS: int = self.main.GM_NPTS[idx]
            duration: float = self.main.GM_durations[idx]
            fv_duration: float = self.main.fv_duration
            T: np.ndarray = self.main.T
            RSA = self.mainWin.RSA[idx]
            Sa_current = Sa0
            if self.mainWin.intensity_measure == 1:
                Sa_original = self.Sa(T, RSA, self.mainWin.T0)  # 以Sa(T)作为地震动强度指标
            elif self.mainWin.intensity_measure == 2:
                Ta, Tb = self.mainWin.T_range
                RSA = self.mainWin.RSA[idx]
                Sa_range = RSA[(Ta <= T) & (T <= Tb)]
                Sa_avg = self.geometric_mean(Sa_range)  # 简单几何平均数
                Sa_original = Sa_avg  
            self.signal_set_progressBar.emit((f'正在计算地震动：{idx+1}/{self.main.GM_N}', int(idx / self.main.GM_N * 100)))
            iter_state = 0  # 迭代状态，当第一次出现倒塌时设为1
            Sa_l, Sa_r = 0, 100000  # 最大未倒塌强度，最小倒塌强度
            for run_num in range(max_ana):
                if self.is_kill == 1:
                    all_break = 1
                    break
                self.main.logger.info(f'\t第{idx+1}条地震动第{run_num+1}次计算')
                self.mainWin.ui.label_20.setText(str(run_num + 1))
                Sa_current = round(Sa_current, 5)
                SF = Sa_current / Sa_original
                self.signal_set_ui.emit((gm_name, f'{Sa_current}g', duration, dt, NPTS))
                time_gm_start = time.time()
                self.signal_add_log.emit(f'开始：{time.strftime("%Y/%m/%d %H:%M:%S", time.localtime(time_gm_start))}\n')
                self.signal_add_log.emit(f'地震动：{gm_name}\n')
                self.signal_add_log.emit(f'步长：{dt}s\n')
                self.signal_add_log.emit(f'步数：{NPTS}\n')
                self.signal_add_log.emit(f'持时：{duration}s\n')
                self.signal_add_log.emit(f'自由振动时间：{fv_duration}s\n')
                self.signal_add_log.emit(f'缩放系数：{SF:.3f}\n')
                if self.mainWin.intensity_measure == 1:
                    text_Sa = 'Sa(T1)'
                elif self.mainWin.intensity_measure == 2:
                    text_Sa = 'Sa,avg'
                self.signal_add_log.emit(f'{text_Sa}：{Sa_current}g\n')
                self.modify_tcl(self.main.Output_dir, gm_name, dt, NPTS, duration, fv_duration, SF, run_num+1)
                cmd = f'"{self.OS_path}" "{self.main.dir_temp}/temp_running_{self.main.model_name}_{gm_name}.tcl"'
                if self.mainWin.test:
                    time.sleep(1)  # 模拟耗时工作
                else:
                    # 运行分析
                    if self.mainWin.print_result:
                        subprocess.call(cmd)
                    else:
                        subprocess.call(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                time.sleep(1)
                if os.path.exists(self.main.dir_temp/ f'{gm_name}_CollapseState.txt'):
                    collapsed = 1
                    self.signal_add_log.emit(f'倒塌：是\n')
                    os.remove(self.main.dir_temp / f'{gm_name}_CollapseState.txt')
                else:
                    collapsed = 0
                    self.signal_add_log.emit(f'倒塌：否\n')
                if not os.path.exists(self.main.Output_dir / f'{gm_name}_{run_num+1}'):
                    os.makedirs(self.main.Output_dir / f'{gm_name}_{run_num+1}')
                np.savetxt(self.main.Output_dir / f'{gm_name}_{run_num+1}/Sa.dat', np.array([Sa_current]))
                with open(self.main.Output_dir / f'{gm_name}_{run_num+1}/isCollapsed.dat', 'w') as f:
                    f.write(str(collapsed))
                time_gm_end = time.time()
                time_cost = time_gm_end - time_gm_start
                self.signal_add_log.emit(f'结束：{time.strftime("%Y/%m/%d %H:%M:%S", time.localtime(time_gm_end))}\n')
                self.signal_add_log.emit(f'该地震动已计算次数：{run_num+1}\n')
                self.signal_add_log.emit(f'该地震动计算耗时：{round(time_cost, 2)}s\n\n')
                if self.mainWin.test:
                    collapsed = 0
                if self.main.trace_collapse:
                    # 追踪倒塌
                    if run_num == 0 and collapsed == 1:
                        self.signal_add_warning.emit(f'{gm_name}首次计算即倒塌！\n\n')
                        self.main.logger.warning(f'{gm_name}首次计算即倒塌！\n\n')
                        break
                    if collapsed == 0 and iter_state == 0:
                        # 如果未倒塌，且不处于迭代状态
                        Sa_l = Sa_current
                        Sa_current += Sa_incr
                    else:
                        # 在迭代状态下，即已经出现过倒塌后
                        iter_state = 1  # 进入迭代状态
                        if collapsed == 1:
                            # 若迭代状态下倒塌，更新最小倒塌强度
                            Sa_r = min(Sa_current, Sa_r)
                        else:
                            # 若迭代状态下未倒塌，更新最大未倒塌强度
                            Sa_l = max(Sa_current, Sa_l)
                        if Sa_l > Sa_r:
                            raise ValueError('最小倒塌强度大于最大未倒塌强度!')
                        if Sa_r - Sa_l < tol:
                            break  # 满足收敛容差，完成当前地震动分析
                        Sa_current = 0.5 * (Sa_l + Sa_r)  # 用于下一次计算的地震强度
                else:
                    # 不追踪倒塌
                    Sa_current += Sa_incr
            else:
                # 超过最大计算次数
                if self.main.trace_collapse:
                    self.mainWin.warning = 1
                    self.signal_add_warning.emit(time.strftime("%Y/%m/%d %H:%M:%S", time.localtime(time_gm_end)) + '\n')
                    self.signal_add_warning.emit(f'地震动{gm_name}在{max_ana}次分析后未能找到倒塌点！\n\n')
                    self.main.logger.warning(f'地震动{gm_name}在{max_ana}次分析后未能找到倒塌点！\n\n')
            os.remove(self.main.dir_temp / f'temp_running_{self.main.model_name}_{self.mainWin.current_gm}.tcl')
            self.main.logger.success(f'第{idx+1}条地震动计算完成')
        else:
            self.signal_finished.emit(1)



    def run_IDA_concurrency(self):
        ...



    def run_pushover(self):
        self.main.logger.info(f'正在Pushover分析')
        self.signal_set_progressBar.emit(('正在进行Pushover分析...', 0))
        gm_name = 'Pushover'
        dt = '0'
        NPTS = '0'
        duration = '0'
        fv_duration = 0
        SF = 1
        self.signal_set_ui.emit((gm_name, '（仅IDA适用）', duration, dt, NPTS))
        time_gm_start = time.time()
        self.signal_add_log.emit(f'开始：{time.strftime("%Y/%m/%d %H:%M:%S", time.localtime(time_gm_start))}\n')
        self.modify_tcl(self.main.Output_dir, gm_name, dt, NPTS, duration, fv_duration, SF)
        cmd = f'"{self.OS_path}" "{self.main.dir_temp}/temp_running_{self.main.model_name}_{gm_name}.tcl"'
        # 运行分析
        if self.mainWin.print_result:
            subprocess.call(cmd)
        else:
            subprocess.call(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if not os.path.exists(self.main.Output_dir / gm_name):
            os.makedirs(self.main.Output_dir / gm_name)
        with open(self.main.Output_dir / gm_name / 'isCollapsed.dat', 'w') as f:
            f.write('2')
        time_gm_end = time.time()
        elapsed_time = time_gm_end - time_gm_start
        self.signal_add_log.emit(f'结束：{time.strftime("%Y/%m/%d %H:%M:%S", time.localtime(time_gm_end))}\n')
        self.signal_add_log.emit(f'耗时：{round(elapsed_time, 2)}s\n\n')
        self.signal_finished.emit(1)




    @staticmethod
    def Sa(T: np.ndarray, S: np.ndarray, T0: float, withIdx=False) -> float:
        for i in range(len(T) - 1):
            if T[i] <= T0 <= T[i+1]:
                k = (S[i+1] - S[i]) / (T[i+1] - T[i])
                S0 = S[i] + k * (T0 - T[i])
                if withIdx:
                    return S0, i
                else:
                    return S0
        else:
            raise ValueError(f'无法找到周期点{T0}对应的加速度谱值！')
        
    @staticmethod
    def geometric_mean(data):  # 计算几何平均数
        total = 1
        for i in data:
            total *= i
        return pow(total, 1 / len(data))


# class WorkerThread_sub(QThread):
#     """opensees求解线程-并发计算子线程
#     """

#     signal_set_ui = pyqtSignal(tuple)  # 运行过程中显式dt，NPTS等
#     signal_set_progressBar = pyqtSignal(tuple)  # 运行过程中设置进度条
#     signal_finished = pyqtSignal(int)  # 运行完成
#     signal_add_log = pyqtSignal(str)  # 增加日志内容
#     signal_add_warning = pyqtSignal(str)  # 增加警告内容

#     def __init__(self, main, mainWin: MyWin):
#         super().__init__()
#         self.main = main
#         self.mainWin = mainWin
#         self.model_name = self.main.model_name
#         self.OS_path: str = main.OS_path
#         self.is_kill = 0




