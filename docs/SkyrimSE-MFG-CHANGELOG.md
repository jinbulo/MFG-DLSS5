# SkyrimSE MFG 更新说明

版本日期：**2026-10-05**（上一版：2026-10-04）
适用游戏：**Skyrim Special Edition** —— `1.5.97` 与 `1.7.104 (AE)` 均已实测跑通（见第五节）

---

## 一、这一版变了什么（相对 2026-10-04）

### 1. 安装脚本改成中英双语

`install.bat` / `mfg-disable.bat` / `mfg-enable.bat` / `restore.bat` 背后跑同一支 `mfg-tool.ps1`，
它打印的每一句话现在都是中英对照。`.bat` 本身保持纯英文注释（cmd 在非 UTF-8 代码页下显示中文
会乱码），玩家实际读到的提示都来自 `.ps1`。

### 2. 安装脚本能自己找到你的游戏

候选顺序：**① 拖拽/命令行给的目录 → ② 脚本所在目录与上一级 → ③ 上次装过的记录 →
④ Bethesda 注册表 → ⑤ 本机所有 Steam 库**（含 `libraryfolders.vdf` 里的第二块 Steam 盘）。
机器上有多份游戏时会列出来让你选。

### 3. 版本闸门：版本不认就不装

装之前读目标目录里的 `SkyrimSE.exe` 版本号。不是 `1.5.97.*` 会打印警告并要求**手动输入 `yes`**；
直接回车就是取消，**游戏目录一个字节都不会动**。（现在 1.7.104 也是可用组合，见第五节，
但闸门仍按 1.5.97 的基线提示。）

### 4. 受保护目录自动提权

目标目录写不进去时（典型的 `C:\Program Files (x86)\Steam\...`），脚本会自己用管理员身份重开。

### 5. 新增启动项 `launch-skse.bat`

双击它就是用 `skse64_loader.exe` 启动；`status` 现在还会直接报告脚本扩展器在不在：

```
Launch entry / 启动项：skse64_loader.exe (ok / 正常)
```

### 6. `ReShade.ini` 修好

截图键统一为 **`F10`**、截图存到**游戏根目录**（`SavePath=.\`），并补齐了 `[SCREENSHOT]` 段；
去掉了包里的作者本机缓存路径。

### 7. **ENB 是必需的**（这一版最重要的结论）

同一支 addon、同一套文件，**唯一差别是有没有装 ENB**：

| | 没装 ENB | 装了 ENB 0.505 |
| --- | --- | --- |
| 接管 / 4 倍帧生成 | 正常 | 正常 |
| 运动矢量 | `MV probe 0.000 px，0% 非零` | `非零占比 100%`，`mean \|mv\| 7.56 px` |

没 ENB 时链路照跑、也能出 4 倍帧，但**插值帧拿不到运动信息，转镜头会拖影**。ENB 在场时引擎才会
把运动矢量交出来。请自行安装 **ENB 0.505**（enbdev 官方，对应现在的 Skyrim SE），本包不含 ENB。

### 8. **必须用无边框窗口**

本层要在同一个窗口上建自己的交换链，**独占全屏下 DXGI 会拒绝**
（日志 `CreateSwapChainForHwnd -> 0x887a0001`，连续 3 次后放弃接管）。实测改成无边框后一次就成功。

用 MO2 的话改 **profile 里的** `skyrimprefs.ini`；不用 MO2（直接跑 Steam 版）就改
`文档\My Games\Skyrim Special Edition\SkyrimPrefs.ini`：

```ini
[Display]
bBorderless=1
bFull Screen=0
```

### 9. AE（1.7.104）也能跑了 —— 但有前提

在 `1.7.104` + SKSE **2.3.1** + ENB 0.505 + 无边框的组合下实测：

```
OURSC | 建立我们自己的 D3D12 FLIP 交换链 -> 0x0 成功
DONE | 已接管窗口（第 308 次 Present）
MFG 实测 | 屏幕实测约 81 帧/秒；应用侧约 20 帧/秒；实测倍数=4（DLSS-G 自报 4）
MVSTATS | 非零占比=100%
```

也就是说 AE 上**接管、4 倍帧生成、运动矢量都成立**。（本层的 AE 适配是靠引擎自己的运动矢量缓冲；
内核里那条"用 PlayerCamera 推算"的兜底路径仍然按 1.5.97 的偏移写死，AE 上不生效——但实测不需要它。）

### 10. 新增 `DOWNGRADE-to-1.5.97.md`

如果你的游戏是 AE 且想让配置回到本 mod 原先标定的 1.5.97，里面有三条 `download_depot` 命令
（含清单号）、覆盖步骤、SKSE 要换回 2.0.20 的说明。

---

## 二、装之前需要什么

| 项目 | 要求 |
| --- | --- |
| 游戏 | Skyrim SE **1.5.97** 或 **1.7.104 (AE)** |
| 脚本扩展 | SKSE64：1.5.97 → **2.0.20**；1.7.104 → **2.3.1** |
| 显示宿主 | **ENB**（1.5.97/1.7.104 都用 enbdev 的 **0.505**）—— **必需**，本包不含 |
| 窗口模式 | **无边框窗口**（`bFull Screen=0`） |
| 显卡 | NVIDIA RTX 40 系或更新（DLSS-G 要求） |
| 其他 | 确认没有别的插帧工具在跑，尤其 `ENBFrameGeneration.dll` 要禁用 |

---

## 三、怎么装

**A. 不用 MO2（推荐，用脚本，会自动备份）**

1. 把压缩包解到**游戏目录之外**（桌面就行）；
2. 双击 `install.bat`，或把游戏目录拖到 `install.bat` 上；
3. 它会自己找游戏目录、**先把会被覆盖的同名文件备份到 `MFG-backup-<时间戳>\`**，再复制进去。

**B. 用 MO2**

把包内文件复制进 `MO2\overwrite\Root`（= 游戏根目录）即可。

---

## 四、怎么启动

**用 `skse64_loader.exe` 启动**（双击包里的 `launch-skse.bat` 同样效果）。不要用
`SkyrimSELauncher.exe`，也别点 Steam 的「开始游戏」——避免 Steam 顺手更新。

---

## 五、1.5.97 与 1.7.104 的差别

| | 1.5.97 | 1.7.104 (AE) |
| --- | --- | --- |
| SKSE64 | 2.0.20 | 2.3.1 |
| 接管 / 4× / ui_exact | 已实测 | 已实测 |
| 运动矢量 | 引擎矢量 + 相机推算（两条路都通） | 靠引擎矢量（实测 100% 非零） |
| 相机兜底路径 | 有效（RVA `0x2EC59B8`，Address Library id 514642） | **不生效**（AE 换了地址，该值硬编码在 addon 里） |
| 结论 | 长时间验证过的组合 | 能跑，但相机兜底没有；想万无一失就用 1.5.97 |

---

## 六、怎么停用 / 还原

| 想做的事 | 双击 |
| --- | --- |
| 暂时不要这一层（随时开回来） | `mfg-disable.bat` |
| 开回来 | `mfg-enable.bat` |
| 彻底卸载、恢复安装前文件 | `restore.bat` |

`restore.bat` 不会删备份目录，确认没问题后可以自己删。

---

## 七、注意事项

1. **必须装 ENB**（0.505），否则没有运动矢量、转镜头拖影。
2. **必须无边框窗口**（`bFull Screen=0`），独占全屏下本层会放弃接管。
3. SKSE 版本要和游戏版本配对：1.5.97 → 2.0.20，1.7.104 → 2.3.1。
4. 本包**不含 ENB**，也不动你的 `d3d11.dll` / `enbseries.ini` / `enblocal.ini`。
5. `ui_exact` 默认开启（UI 不进 DLAA，保持原像素）；HUD 异常时先把它改成 `0` 对比。
6. `hudless_tag` 只接受 `0/1`（写 ≥2 会被钳回 1）—— 2/3 那条路已按实测删除。
7. 帧数倍率看 `SkyrimMFG.ini` 的 `mfg_frames`（1 = 2×，2 = 3×，3 = 4× …）。
8. 想调/换 ENB 预设：本包不管 ENB，直接换 `enbseries\` 里的预设即可。

---

## 八、快捷键

| 键 | 作用 |
| --- | --- |
| `F5` | RenoDX 神经渲染 截图 |
| `F6` | RenoDX 神经渲染 开/关 |
| `F7` | ReShade 覆盖层 开/关 |
| `F8` | ReShade 效果总开关 |
| `F10` | ReShade 截图（存**游戏根目录**） |

---

## 九、日志在哪（排错用）

都在**游戏根目录**：

| 文件 | 看什么 |
| --- | --- |
| `SkyrimMFG.log` | 接管是否成功、`slInit`、帧数/倍率、`ui_exact`、运动矢量来源与 `MVSTATS` |
| `dlss5-feed.log` | DLSS5 喂帧：工作分辨率、`MV probe`、深度探针、GPU 耗时 |
| `ReShade.log` | ReShade 与 RenoDX：依赖链、`NR-VERDICT`、效果编译 |
| `sl.log` | Streamline / DLSS-G：`slInit`、钩子、`shouldInterpolate` |

---

## 十、这一版动过的文件

| 文件 | 变化 |
| --- | --- |
| `mfg-tool.ps1` | 中英双语；Steam 库扫描；版本闸门；自动提权；显式目录不再弹菜单；新增 `launch` 动作与状态里的启动项检查 |
| `install.bat` / `mfg-disable.bat` / `mfg-enable.bat` / `restore.bat` | 保持英文注释（ASCII），功能同上 |
| `ReShade.ini` | 截图键 `F10`、存游戏根目录、补 `[SCREENSHOT]` 段、去掉作者本机路径 |
| **新增** `launch-skse.bat` | 一键用 `skse64_loader.exe` 启动 |
| **新增** `DOWNGRADE-to-1.5.97.md` | AE 退回 1.5.97 的完整步骤（含 depot 清单号） |
| `README.md` | ENB 从"可选"改回"必需"，并附实测对照表；安装前提/需求表/致谢同步 |
| `更新说明.md` | 本文件 |
