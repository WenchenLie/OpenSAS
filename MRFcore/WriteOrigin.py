import sys
import shutil
from pathlib import Path
from typing import Literal
import originpro


def origin_shutdown_exception_hook(exctype, value, traceback):
    '''Ensures Origin gets shut down if an uncaught exception'''
    op.exit()
    sys.__excepthook__(exctype, value, traceback)


class WriteOrigin():
    def __init__(self, op: originpro, folder: str | Path, file_name: str, file_exists: Literal['o', 'd']='d', set_show: bool=False) -> None:
        """写入origin文件

        Args:
            folder (str | Path): 输出文件夹
            file_name (str): 生成的origin文件名(带后缀)
            file_exists (Literal['o', 'd'], optional): 如果origin文件存在如何处理(o-覆盖, d-删除), 默认"d"
            set_show (bool, optional): 是否显示origin窗口, 默认False
        """
        folder = Path(folder)
        if (folder / file_name).exists():
            print(f'文件已存在: {str((folder / file_name).absolute())}')
            if file_exists == 'd':
                print('将删除')
                shutil.rmtree(folder / file_name)
            elif file_exists == 'o':
                print('将覆盖')
            else:
                raise ValueError('错误参数`file_exists`')
        self.folder = folder
        self.file_name = file_name
        self.op = op
        self.set_show = set_show

    def __enter__(self):
        if self.op and self.op.oext:
            sys.excepthook = origin_shutdown_exception_hook
        if self.op.oext:
            self.op.set_show(self.set_show)
        self.op.new()
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        res = self.op.save(str((self.folder / self.file_name).absolute()))
        if self.op.oext:
            self.op.exit()
        return False
    

if __name__ == "__main__":
    
    import originpro as op
    with WriteOrigin(op, Path(__file__).parent, 'test222.opju', set_show=True) as f:
        dest_wks = op.new_sheet('w')

