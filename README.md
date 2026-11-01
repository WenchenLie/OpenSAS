# OpenSAS

用于框架结构OpenSees时程分析、IDA、易损性分析及地震风险评估的Windows程序。

## 安装依赖

推荐使用uv管理项目环境。Tcl分析与后处理支持Python 3.12、3.13：

```powershell
uv sync
```

若需使用Python模型（`script='py'`），Windows版OpenSeesPy 3.8后端使用Python 3.12：

```powershell
uv sync --python 3.12 --extra opensees
```

选择Python 3.12会使uv按该版本重建项目虚拟环境。仅运行Tcl模型时无需安装`opensees`额外依赖。
