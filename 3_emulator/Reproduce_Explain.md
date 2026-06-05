GP 超参数优化是非凸问题，对微小环境差异极度敏感。


windspeed 训练流程：
X (121×5) → StandardScaler → 87个PC → GridSearchCV
                                        ↓ 
                            3种kernel × 10次随机重启 = 30次优化
                                        ↓
                            找到"最优"kernel超参数
这30次优化每次都从不同随机起点出发，寻找 log-likelihood 的局部最大值。以下任何微小差异都会改变收敛路径：

因素	说明
sklearn 版本	本地 Mac vs 服务器可能版本不同，optimizer 内部实现有差异
numpy 版本	浮点运算累积误差路径不同
CPU 架构	Mac (ARM/x86) vs 服务器 (x86)，浮点计算顺序不同
训练时间不同	sm 和 windspeed 可能在不同 paleo_emu commit 下训练
一旦找到不同的 kernel 超参数（比如 length scale 差了 10%），预测结果可能差很多——GP 是全局平滑的，超参数的细微不同会影响所有 1001 个时间步的预测。

结论：对于没有 NaN 的变量，代码逻辑差异不是原因，根本原因是 GP 优化在非凸空间里找到了不同的局部最优解，这在不同环境（本地/服务器）之间几乎不可避免。

要完全复现旧结果，唯一可靠的方法是直接使用旧 joblib 文件，而不是重新训练。