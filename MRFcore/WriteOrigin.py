import sys
import shutil
from pathlib import Path
from typing import Literal
import originpro



class WriteOrigin():
    def __init__(self, op: originpro, opju_file: Path, folder_name:str, set_show: bool=False) -> None:
        """写入origin文件

        Args:
            op (originpro): originpro对象
            opju_file (Path): opju的路径，数据将保存到这个文件，若该opju文件不存在则将创建，若存在则将打开并写入数据
            set_show (bool, optional): 是否显示origin窗口, 默认False
        """
        self.op = op
        self.opju_file = opju_file
        self.folder_name = folder_name
        self.set_show = set_show

    def __enter__(self):
        if self.op and self.op.oext:
            sys.excepthook = self.origin_shutdown_exception_hook
        if self.op.oext:
            self.op.set_show(self.set_show)
        if not self.opju_file.exists():
            # 如果opju文件不存在则创建
            self.op.new(self.opju_file.absolute().as_posix())
            fd = self.op.pe.active_folder()
            fd.name = self.folder_name
        else:
            # 如果存在则打开
            self.op.open(self.opju_file.absolute().as_posix())
            res0 = None
            while True:
                res1 = self.op.pe.cd('..')
                if res0 == res1:
                    break  # 返回上级origin文件夹，直至最顶层
                res0 = res1
            self.op.pe.mkdir(self.folder_name, True)  # 创建origin文件夹，如果已经存在则不会创建
            self.op.pe.cd(self.folder_name)  # 进入origin文件夹
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.op.save(str(self.opju_file.absolute()))
        if self.op.oext:
            self.op.exit()
        return False
    
    def origin_shutdown_exception_hook(self, exctype, value, traceback):
        '''Ensures Origin gets shut down if an uncaught exception'''
        self.op.exit()
        sys.__excepthook__(exctype, value, traceback)

    def delete_obj(self, obj_name: str):
        """删除表格

        Args:
            obj_name (str.WBook): 表格名
        """
        wb = self.op.find_book('w', obj_name)
        if wb:
            wb.destroy()


if __name__ == "__main__":
    pass
    
    # import originpro as op
    # with WriteOrigin(op, Path(__file__).parent, 'test222.opju', set_show=True) as f:
    #     dest_wks = op.new_sheet('w')

