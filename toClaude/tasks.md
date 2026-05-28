# NWS Task List

所有路径以 `OneDrive-UniversityofBristol/` 为根。

## 通用规则（来自 CLAUDE.md）

> 1. **备份原则**：Claude 在修改任何已有文件前，必须先在同目录创建备份，命名格式为 `{原文件名}_backup_{YYYYMMDD}`。
> 2. **命名规则**：Claude 新建的所有代码文件（`.py` / `.ipynb` / `.yml` 等）必须以 `CC_` 开头，用以区分 Xin 自己写的代码。

---

## Task 1 — 单个 member 的 ice sheet stackplot（无 ensemble）

**目标：** 重画 ice sheet stackplot，只显示第 67 个 member（Python 索引 66），不画 ensemble 汇总。

**源文件：** `NWS-PDRA/NWS_emulation/prediction/plot+scripts/Plot_strip_IS.ipynb`

**修改说明：**
- 现有代码在 Cell 7 中对所有 90 个 member 做 `process_data()`，Cell 10 绘制 stacked area % + pie chart
- 改成：只取 `all_data[scen_idx][66, :]`（单个 member 的时间序列），直接画 0/1 的折线或 binary 条带图
- 不需要 pie chart（只有一个 member 没有比例意义）
- 6 个 scenario 各画一行，layout 保持不变

**执行方式：**
- 不修改 `Plot_strip_IS.ipynb`；新建 `CC_Plot_strip_IS_member67.ipynb`（放在同目录）

**输出：** `NWS-PDRA/NWS_emulation/prediction/plot+scripts/plots/ice_sheet_site_LA_stackplot_with_pie_67.png`（不覆盖原图）

---

## Task 2 — 4 种 regime 的 ensemble stackplot（所有 member）

**目标：** 将现有的 2 种 regime（有冰/无冰）扩展为 4 种，加入 GSL 判断：

| Regime | 条件 |
|--------|------|
| Aerial + ice | GSL ≥ −25 m 且 ice sheet = 1 |
| Aerial + no ice | GSL ≥ −25 m 且 ice sheet = 0 |
| Under sea + ice | GSL < −25 m 且 ice sheet = 1 |
| Under sea + no ice | GSL < −25 m 且 ice sheet = 0 |

**GSL 数据来源：**
- 每个 member 的 GSL 时间序列来自 `TONIC-Oligocene/Emulator_Xin/2025_Bristol_5D_v002_Xin/Conceptual-GSL/PosivaSKB-master/Results/emul_inputs_{scenario}.{member}.updated.res`
- 列名为 `ice`（global sea level，单位 m），从 `Plot_CO2+GSL.ipynb` Cell 1 可见读取方式

**GSL 阈值：** -28 m（来自 CO2_GSL_SSP.png 图 2 的黑色虚线参考线）

**执行方式：**
- 不修改 `Plot_strip_IS.ipynb`；新建 `CC_Plot_strip_IS_4regime.ipynb`（放在同目录）

**修改逻辑：**
- 对每个 scenario，逐 member 逐时间步读取 ice_sheet（0/1）和 GSL 值
- 按 4 种 regime 统计各时间步的 member 数量，画 stacked area（4 色）+ pie chart（4 色）
- 配色建议：Aerial+ice=白, Aerial+no ice=深绿, Under sea+ice=浅蓝, Under sea+no ice=深蓝

**输出：** `NWS-PDRA/NWS_emulation/prediction/plot+scripts/plots/ice_sheet_site_LA_4regime_allMembers.png`（新文件，不覆盖原图）

---

## Task 3 — 4 种 regime，仅第 67 个 member

**目标：** 在 Task 2 的 4-regime 框架下，只展示 member 67（索引 66）

**说明：**
- 单个 member 的 GSL 和 ice_sheet 都是确定值（非比例），可以画 binary 条带或直接标注 regime 颜色
- 不需要 pie chart

**执行方式：**
- 新建 `CC_Plot_strip_IS_4regime_member67.ipynb`（放在同目录，复用 Task 2 的逻辑）

**输出：** `NWS-PDRA/NWS_emulation/prediction/plot+scripts/plots/ice_sheet_site_LA_4regime_member67.png`（新文件）

---

## Task 4 — CO₂ validation 图图例修改 ⚠️ MATLAB，需手动修改

**目标图：** `TONIC-Oligocene/Emulator_Xin/2025_Bristol_5D_v002_Xin/Conceptual-GSL/PosivaSKB-master/CO2model_validation_updated.png`

**图例修改：**
- `my xxx` → `this study: xxx`
- `original xxx` → `TR 19-09: xxx`

**源脚本：** MATLAB 文件（需要你自己确认是哪个 `.m` 文件，可能是 `plot_Figure3_4a_Xin.m`）

> 🔧 **手动操作**：找到生成该图的 MATLAB 脚本中的 `legend(...)` 调用，将标签改为上述格式后重新运行。

---

## Task 5 — GSL validation 图图例修改 ⚠️ MATLAB，需手动修改

**目标图：** `TONIC-Oligocene/Emulator_Xin/2025_Bristol_5D_v002_Xin/Conceptual-GSL/PosivaSKB-master/GSLmodel_validation.png`

**图例修改：** 同 Task 4，将 `my xxx` → `this study: xxx`，`original xxx` → `TR 19-09: xxx`

**源脚本：** MATLAB 文件（可能是 `plot_Figure3_4b_Xin.m` 或相似文件）

> 🔧 **手动操作**：同 Task 4。

---

## Task 6 — LOO validation 图 subtitle 修改

**目标图：** `NWS-PDRA/NWS_RSO_report_2026/appendix_plot/LOOvalidation.png`

**修改说明：**
- 当前 subtitle 写的是 `Old RMSE` / `New RMSE`
- 改为：`RMSE (TR 19-09): {value:.4f}` / `RMSE (this study): {value:.4f}`

**执行方式：**
- 备份原 notebook：`TEST.RMSE.Calc_multiExp_backup_YYYYMMDD.ipynb`
- 在备份基础上修改，或新建 `CC_Plot_LOOvalidation_relabelled.ipynb`

**RMSE 数值来源：**
- Old RMSE：从 TR 19-09 原报告 Pg31 读取（TR-19-09.pdf），或 `LOO_RMSE_modhighice.res` 与 `LOO_RMSE_modlowice.res`
- New RMSE：`LOO_RMSE_modhighice_alltrain.res` 与 `LOO_RMSE_modlowice_alltrain.res`

> ⚠️ 请确认：subtitle 里需要显示哪个具体的 RMSE 数值（单个平均？还是逐 case 列出）？

---

## Task 7 — 重跑完整 workflow（Historical_emissions bug 修复）

### 背景

`CO2_calculation/Convoluted_response_function.ipynb` 中：
```python
Historical_emissions = 355.558    # 当前值，是为了"fit previous report"手动设置的
#157.2594447803                    # 被注释掉的备选值，来源不明
```

**错误原因：** 我们的 SSP emissions 文件从 **2000年** 开始（见 `Create_SSP_emissions.ipynb`），所以 `Historical_emissions` 应等于 **1765年到2000年之前（含2000年）的累计 CO₂ 排放量**。

根据 `RCP85_EMISSIONS.DAT`（FossilCO₂ + OtherCO₂，1765–2000 inclusive）计算：

| 区间 | 累计排放 (GtC) |
|------|---------------|
| 1765 to 2000 (inclusive) | **430.715** |
| 1765 to 1999 (exclusive of 2000) | 422.831 |

> ⚠️ **待确认：** 正确值是 430.715 还是其他值？注释里的 157.25 是什么？请查清楚后再进行 Task 7。
>
> 建议参考：原始 Lord et al. 论文或 TR-19-09 中 Historical emissions 的定义，以及 Natalie 使用的 RCP 版本。

**受影响的 scenarios：** SSP119, SSP126, SSP245, SSP370, SSP460, SSP534, SSP585, 10000PGC（共 8 个）
**不需要重跑：** natural scenario

---

### 7a — 修复 Historical_emissions

**文件：** `TONIC-Oligocene/Emulator_Xin/2025_Bristol_5D_v002_Xin/CO2_calculation/Convoluted_response_function.ipynb`

**执行方式：**
- 先备份：`Convoluted_response_function_backup_YYYYMMDD.ipynb`
- 然后修改备份中的值：

```python
# 将这行：
Historical_emissions = 355.558
# 改为（待确认正确值后填入）：
Historical_emissions = ⚠️_TBD    # cumulative CO2 1765–2000 (GtC)
```

> 🔧 由 Claude 修改（先备份再改），确认数值后执行。

---

### 7b — 重跑 SSP emissions 文件生成

> ⚠️ **注意：** `Create_SSP_emissions.ipynb` 生成的是原始 SSP 排放量时间序列，与 `Historical_emissions` 无关，**不需要重跑**。只有 `Convoluted_response_function.ipynb`（步骤 7c）才使用 `Historical_emissions`。

---

### 7c — 重跑 CO₂ ppmv 计算（8 个 scenarios）

**文件：** `TONIC-Oligocene/Emulator_Xin/2025_Bristol_5D_v002_Xin/CO2_calculation/Convoluted_response_function.ipynb`（已在 7a 中备份）

对 Cell 2 中每个 scenario 逐一执行，输出文件：
- `SSP/CO2_SSP1-19_ppmv.txt`
- `SSP/CO2_SSP1-26_ppmv.txt`
- `SSP/CO2_SSP2-45_ppmv.txt`
- `SSP/CO2_SSP3-70_ppmv.txt`
- `SSP/CO2_SSP4-60_ppmv.txt`
- `SSP/CO2_SSP5-34_ppmv.txt`
- `SSP/CO2_SSP5-85_ppmv.txt`
- `SSP/CO2_10000pgc_ppmv.txt`

> 🔧 由 Claude 执行（需在 notebook 对应工作目录下运行）。

---

### 7d — 重跑 CO₂ ppmv → 1 Ma 格式转换

**文件：** `TONIC-Oligocene/Emulator_Xin/2025_Bristol_5D_v002_Xin/CO2_calculation/make_CO2_ppmv_data_in_ka.ipynb`

**执行方式：** 先备份 `make_CO2_ppmv_data_in_ka_backup_YYYYMMDD.ipynb`，然后原地运行。

> 🔧 由 Claude 执行。

---

### 7e — 重跑 GSL model（MATLAB）⚠️ 手动

**文件：** `TONIC-Oligocene/Emulator_Xin/2025_Bristol_5D_v002_Xin/Conceptual-GSL/PosivaSKB-master/Archer_Ganopolski_2005_rcp_4_1myrAP_LHC_sens_test_atka_Xin.m`

> 🔧 **手动操作**：在 MATLAB 中运行此脚本（每个 SSP scenario）。

---

### 7f — 重跑 Figure3_4a 图（MATLAB）⚠️ 手动

**文件：** `TONIC-Oligocene/Emulator_Xin/2025_Bristol_5D_v002_Xin/Conceptual-GSL/PosivaSKB-master/plot_Figure3_4a_Xin.m`

> 🔧 **手动操作**：在 MATLAB 中运行此脚本。

---

### 7g — 重跑 Create_Samp_SSP_upd_1myr_AP

**文件：** `TONIC-Oligocene/Emulator_Xin/2025_Bristol_5D_v002_Xin/Conceptual-GSL/PosivaSKB-master/inputX/orig/Create_Samp_SSP_upd_1myr_AP.ipynb`

**执行方式：** 先备份 `Create_Samp_SSP_upd_1myr_AP_backup_YYYYMMDD.ipynb`，然后原地运行。

> 🔧 由 Claude 执行。

---

### 7h — 重跑 updated CO₂ from RSL（MATLAB）⚠️ 手动

**文件：** `TONIC-Oligocene/Emulator_Xin/2025_Bristol_5D_v002_Xin/Conceptual-GSL/PosivaSKB-master/updated_CO2_from_RSL_rcp_4_1myrAP_from800kyrBP_RCP_LHC_Xin.m`

> 🔧 **手动操作**：在 MATLAB 中运行，对所有 8 个 non-natural scenarios 执行。

---

### 7i — 重跑 update_CO2_LHC_members

**文件：** `TONIC-Oligocene/Emulator_Xin/2025_Bristol_5D_v002_Xin/Conceptual-GSL/PosivaSKB-master/update_CO2_LHC_members.ipynb`

**执行方式：** 先备份 `update_CO2_LHC_members_backup_YYYYMMDD.ipynb`，然后原地运行。

> 🔧 由 Claude 执行。

---

### 7j — 重跑 emulator 预测（全变量，两种 ice state）

**文件：** `NWS-PDRA/NWS_emulation/prediction/run_prediction.py`

步骤：
1. 训练 + 预测 `modhighice`：10 个变量 × 8 scenarios × 90 members
2. 训练 + 预测 `modlowice`：10 个变量 × 8 scenarios × 90 members
3. 输出到 `/Volumes/Xin-data/result/`（外接硬盘）

> ⚠️ 运行前确认外接硬盘 `/Volumes/Xin-data/` 已挂载。
> 🔧 由 Claude 发起（执行时间长，建议 background 运行）。

---

## 任务顺序总结

| 任务 | 谁来做 | 前置依赖 |
|------|--------|---------|
| Task 1 | Claude | 无 |
| Task 2 | Claude | 无 |
| Task 3 | Claude | Task 2 逻辑 |
| Task 4 | **手动** | 无 |
| Task 5 | **手动** | 无 |
| Task 6 | Claude | 无 |
| Task 7a | Claude（确认值后） | ⚠️ 待确认 Historical_emissions 正确值 |
| Task 7c | Claude | Task 7a |
| Task 7d | Claude | Task 7c |
| Task 7e | **手动** | Task 7d |
| Task 7f | **手动** | Task 7e |
| Task 7g | Claude | Task 7f |
| Task 7h | **手动** | Task 7g |
| Task 7i | Claude | Task 7h |
| Task 7j | Claude | Task 7i |
