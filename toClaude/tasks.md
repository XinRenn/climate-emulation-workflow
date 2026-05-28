# NWS Task List

所有路径以 `OneDrive-UniversityofBristol/` 为根，除非注明 `climate_emulation_workflow/`（新 repo）。

---

## 当前 session 进度（2026-05-28）

### 已完成
- ✅ **Tasks 1–6** — 全部完成（见下方各任务详情）
- ✅ **GitHub repo 建立** — `https://github.com/XinRenn/climate-emulation-workflow`（private）
  - 本地路径：`NWS-PDRA/climate_emulation_workflow/`
- ✅ **Task 7a** — `Historical_emissions = 283.962 GtC` 已手动修改
- ✅ **Task 7c + 7d（Stage 1）** — 已运行，一切顺利
- ✅ **脚本重命名** — 用数字前缀标注步骤顺序（如 `1.xxx.ipynb`）；README 路径待明天 update

### 待完成（明天继续）
- ⏳ **Update README** — 因脚本已重命名，需更新 README 中的文件名和路径
- ⏳ **Tasks 7e–7j（Stage 2 起）** — 继续修改并运行 Stage 2，之后 Stage 3

---

## 新 repo 代码修改规则（climate_emulation_workflow/）

> ⚠️ 与原工作目录的规则不同：
> 1. **无需 `CC_` 前缀**（新文件无需加前缀）
> 2. **尽量小改动原有代码**
> 3. **每次修改代码前必须告知用户**
> 4. **仍需备份**（修改前创建 `{原文件名}_backup_{YYYYMMDD}`）
>
> 原工作目录（`TONIC-Oligocene/`、`NWS-PDRA/NWS_emulation/`）的规则不变：备份 + CC_ 前缀。

---

## Task 1 — 单个 member 的 ice sheet stackplot（无 ensemble）✅ 完成

**输出文件：** `NWS-PDRA/NWS_emulation/prediction/plot+scripts/CC_Plot_strip_IS_member67.ipynb`
已复制至：`climate_emulation_workflow/4_plots/CC_Plot_strip_IS_member67.ipynb`

---

## Task 2 — 4 种 regime 的 ensemble stackplot（所有 member）✅ 完成

**输出文件：** `NWS-PDRA/NWS_emulation/prediction/plot+scripts/CC_Plot_strip_IS_4regime.ipynb`
已复制至：`climate_emulation_workflow/4_plots/CC_Plot_strip_IS_4regime.ipynb`

GSL 阈值：-28 m（来自 CO2_GSL_SSP.png 图 2 黑色虚线）

---

## Task 3 — 4 种 regime，仅第 67 个 member ✅ 完成

**输出文件：** `NWS-PDRA/NWS_emulation/prediction/plot+scripts/CC_Plot_strip_IS_4regime_member67.ipynb`
已复制至：`climate_emulation_workflow/4_plots/CC_Plot_strip_IS_4regime_member67.ipynb`

---

## Task 4 — CO₂ validation 图图例修改 ✅ 完成

**输出文件：** `TONIC-Oligocene/Emulator_Xin/2025_Bristol_5D_v002_Xin/Conceptual-GSL/PosivaSKB-master/CC_Compare_UpdatedCO2_with_NataResults.ipynb`

图例：`My xxx` → `this study: xxx`，`Original xxx` → `TR 19-09: xxx`

---

## Task 5 — GSL validation 图图例修改 ✅ 完成

**输出文件：** `TONIC-Oligocene/Emulator_Xin/2025_Bristol_5D_v002_Xin/Conceptual-GSL/PosivaSKB-master/CC_Compare_GSL_with_NataResults.ipynb`

---

## Task 6 — LOO validation 图 subtitle 修改 ✅ 完成

---

## Task 7 — 重跑完整 workflow（Historical_emissions bug 修复）

### 背景与确认值

**确认值：`Historical_emissions = 283.962 GtC`**

根据：
- `Create_SSP_emissions.ipynb`：SSP emissions 文件从 **2000年** 开始（`year > 1999`，即第一个数据点是 2000 年排放量）
- `get_co2_from_DAT.ipynb`：fossil-only 1765–2000 inclusive = **283.962 GtC**
- Lord (2017) 论文：使用 fossil-only（不含 land use 等 other emissions），与 Xin 的 SSP 文件中只含 fossil CO₂ 的 IAMC 数据一致
- 原始错误值 355.558 是 fossil-only 到 ~2010 年的累计量（Lord 的 logistics series 从 2010 年开始，不适用于 Xin 从 2000 年开始的 setup）

**受影响 scenarios（共 8 个）：** SSP1-19, SSP1-26, SSP2-45, SSP3-70, SSP4-60, SSP5-34, SSP5-85, 10000pgc
**不需要重跑：** natural scenario

---

### 7a — 修复 Historical_emissions ✅ 完成（手动）

`climate_emulation_workflow/1_CO2_model/1.Convoluted_response_function.ipynb` 中已改为 `283.962`。

---

### 7c — 重跑 CO₂ ppmv 计算（8 个 scenarios）✅ 完成

`1_CO2_model/1.Convoluted_response_function.ipynb` 已运行，输出 `SSP/CO2_*_ppmv.txt`。

---

### 7d — 重跑 CO₂ ppmv → 1 Ma 格式转换 ✅ 完成

`1_CO2_model/2.make_CO2_ppmv_data_in_ka.ipynb` 已运行，输出到 `2_GSL_model/ForcingData/`。

---

### 7e — 重跑 GSL model（MATLAB）⚠️ 手动

**文件：** `climate_emulation_workflow/2_GSL_model/Archer_Ganopolski_2005_rcp_4_1myrAP_LHC_sens_test_atka_Xin.m`

> 🔧 **手动操作**：在 MATLAB 中运行，对所有 8 个 non-natural scenarios。

---

### 7f — 重跑 Figure3_4a 图（MATLAB）⚠️ 手动

**文件：** `climate_emulation_workflow/2_GSL_model/plot_Figure3_4a_Xin.m`

> 🔧 **手动操作**。

---

### 7g — 重跑 Create_Samp_SSP_upd_1myr_AP ⏳ 待执行（Claude）

**文件：** `climate_emulation_workflow/2_GSL_model/inputX/orig/Create_Samp_SSP_upd_1myr_AP.ipynb`

> 🔧 由 Claude 执行（先备份再运行）。

---

### 7h — 重跑 updated CO₂ from RSL（MATLAB）⚠️ 手动

**文件：** `climate_emulation_workflow/2_GSL_model/updated_CO2_from_RSL_rcp_4_1myrAP_from800kyrBP_RCP_Xin.m`

> 🔧 **手动操作**，对所有 8 个 non-natural scenarios。

---

### 7i — 重跑 update_CO2_LHC_members ⏳ 待执行（Claude）

**文件：** `climate_emulation_workflow/2_GSL_model/update_CO2_LHC_members.ipynb`

> 🔧 由 Claude 执行（先备份再运行）。

---

### 7j — 重跑 emulator 预测（全变量，两种 ice state）⏳ 待执行（Claude）

**文件：** `climate_emulation_workflow/3_emulator/run_prediction.py`（配合 `prediction.yml`）

步骤：
1. 训练 + 预测 `modhighice`：10 个变量 × 8 scenarios × 90 members
2. 训练 + 预测 `modlowice`：10 个变量 × 8 scenarios × 90 members
3. 输出到 `/Volumes/Xin-data/result/`（外接硬盘）

> ⚠️ 运行前确认外接硬盘 `/Volumes/Xin-data/` 已挂载。
> 🔧 由 Claude 发起（执行时间长）。

---

## 任务顺序总结

| 任务 | 谁来做 | 状态 | 前置依赖 |
|------|--------|------|---------|
| Tasks 1–6 | Claude | ✅ 完成 | — |
| Repo 建立 | Claude | ✅ 完成 | — |
| Task 7a | Claude | ⏳ 待执行 | 已确认值 283.962 |
| Task 7c | Claude | ⏳ 待执行 | Task 7a |
| Task 7d | Claude | ⏳ 待执行 | Task 7c |
| Task 7e | **手动** | ⏳ 待执行 | Task 7d |
| Task 7f | **手动** | ⏳ 待执行 | Task 7e |
| Task 7g | Claude | ⏳ 待执行 | Task 7f |
| Task 7h | **手动** | ⏳ 待执行 | Task 7g |
| Task 7i | Claude | ⏳ 待执行 | Task 7h |
| Task 7j | Claude | ⏳ 待执行 | Task 7i |
