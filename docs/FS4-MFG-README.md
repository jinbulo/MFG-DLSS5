# FS4 MFG — Real Multi-Frame Generation + DLSS 5 Neural Rendering for Fallout 4

---

## Description

Fallout 4 has neither DLSS nor frame generation. This mod gives it both — for real.

It builds its own D3D12 swapchain over the game's window and drives NVIDIA Streamline / DLSS-G
itself, so the game gets genuine multi-frame generation (2x / 4x / 6x) **without the game
supporting DLSS**. Interpolated frames are produced by the driver's frame generator, not by a
post-process filter.

On top of that it wires DLSS 5 into the same chain: DLSS / DLAA upscaling and neural rendering
come from `dlss5-feed` + `renodx-dlss5`, and this mod feeds them the **engine's real TAA motion
vectors** — taken straight from the game's own motion buffer — instead of optical flow. Optical
flow has to guess; a geometric vector does not. In practice that means a fast camera turn no
longer smears: measured motion reads exactly 0 px when you stand still and tens of px when you
turn, with no outliers.

Nothing in the game folder is modified. Disabling is one double-click (`mfg-disable.bat`).

---

## What's new in this version (2026-10-04)

- **The UI no longer goes through the DLAA pass — new `ui_exact`, on by default.**
  The feed's DLAA used to run on the finished frame, scene *and* HUD together, so the HUD was
  temporally reprojected with the world's motion vectors and came out soft. The add-on now keeps the
  finished frame **B**, hands the upscaler the scene-only frame **A**, and composites the UI's exact
  per-pixel contribution back on top: `presented = saturate(DLAA(A) + B − A)`. No mask, no
  threshold, no dilation, no edge bleed — any HUD, any resolution, translucency included. Verified
  in free play: 100% of frames ran the whole path, and the "scene without HUD" frame was picked
  correctly in 29 of 30 sampled frames.
- **Removed `hudless_tag=2/3`.** Handing DLSS-G a real HUD-less frame over a second shared bridge was
  measured twice on 2026-10-02 and was worse both while moving and while turning. The code is gone;
  the setting is a plain 0/1 again and anything ≥2 is clamped back to 1.
- **ENB is required for motion vectors** (still not bundled). The previous upload carried the
  author's own ENB (`d3d11.dll`, `enbseries.ini`, `enblocal.ini`); this archive still does not
  ship one — install ENB yourself from enbdev.com (FO4 **0.496** for game 1.10.163, **0.501** for
  1.11.x). Measured, same install and same add-on, the only difference being ENB:
  `MV probe 0.000 px / 0% non-zero` without it, `100% non-zero` (values climbing 0.02 → 20 px as
  the camera turns) with it. Without ENB the layer still takes the window over and runs 4x frame
  generation, but DLSS-G gets no motion vectors and the interpolated frames smear.
- **Install / disable / restore scripts.** You no longer need MO2: `install.bat` finds your game
  folder, **backs up every file it is about to overwrite**, and copies the mod in — and
  `mfg-disable.bat` / `mfg-enable.bat` / `restore.bat` turn the layer off, back on, or remove it
  completely.
- **HUD-less detection fixed for Fallout 4.** FO4 binds the back buffer without depth several times
  per frame. Only the *first* of those is the post-processed scene before the HUD — the later ones
  are the finished frame itself. The capture point now takes the first. (On Skyrim the *last* one is
  the right answer, which is why the same code needs a per-title rule.)
- **Hotkeys unified:** F8 toggles effects, F7 the overlay, F12 takes a screenshot (no Ctrl modifier).
  Seven unused bindings were dropped.
- **`wire-shot.bat`** writes into a `shots` folder next to itself instead of a hard-coded path.

**Known issues**

- The geometry mask in the upscaler's guide chain is still needed — **do not set `GEOM_ENABLE=0`**;
  with it off the guide chain trusts motion vectors that are not valid there and subtitles visibly
  blur.
- The HUD is still interpolated inside *generated* frames (that is DLSS-G's own HUD handling).
  `ui_exact` fixes the DLAA blur, not the interpolation.
- Occasional multi-millisecond hitches on the copy, and rare multi-hundred-millisecond frames
  inside the DLSS feed. Under investigation.

---

## Installation instructions

Install **Fallout 4 v1.10.163** (or **v1.11.240**) with the **matching F4SE** — 1.10.163 → F4SE
0.6.23, 1.11.240 → F4SE 0.7.9 — and **ENB** (0.496 / 0.501 respectively). Then pick **one** of the
two paths:

**A. No mod manager (recommended for most players — it backs things up for you)**

1. Extract this archive to a folder **outside** your game folder (the Desktop is fine).
2. Run **`install.bat`**.
3. It finds your game folder, backs up every file it is about to overwrite into
   `MFG-backup-<timestamp>\`, and copies the mod in. If it cannot find the game, drag your
   Fallout 4 folder onto `install.bat`.

**B. Mod Organizer 2**

Copy everything in this archive into your MO2 `overwrite\Root` (that folder is your game root).
The scripts are ignored in this path — you can leave them in the archive.

**Both paths, finish with:**

4. Copy `Data\F4SE\Plugins\fs4mvcam.dll` into `<your game>\Data\F4SE\Plugins\`. (Path A does this
   for you; path B needs it by hand.) This plugin publishes the engine's camera pose and
   previous-frame pose — the mod needs it.
5. **Turn NVIDIA Smooth Motion off** (NVIDIA app / control panel). It is frame generation too,
   and the two will fight each other.
6. Launch the game.

**This archive contains no ENB.** Install ENB yourself — it is what makes the engine publish the
motion vectors this mod feeds to DLSS-G. Yours is never overwritten.

**Logs.** `log_path` in `fs4mfg.ini` ships empty, so `fs4mfg.log` is written next to the add-on.
If a mod manager's virtual file system interferes with writes, point `log_path` at a folder
outside the game, e.g. `log_path=D:\MFG-log\fs4mfg.log`.

| What you want | Run |
| --- | --- |
| Turn the layer off for now (fully reversible) | `mfg-disable.bat` |
| Turn it back on | `mfg-enable.bat` |
| Uninstall — put the backed-up originals back and delete what this pack added | `restore.bat` |

`mfg-disable.bat` only renames the layer's entry points (`dxgi.dll`, `fs4mfg.addon64`,
`dlss5-feed.addon64`, `renodx-dlss5.addon64`, `FO4ReShadeHelper.addon64`) to `.off`; nothing is
deleted and the game immediately returns to its normal present path. `enabled=0` in `fs4mfg.ini`
also makes the layer passive without moving any file.

**Verify it is working** — three lines:

- `fs4mfg.log` → `MFG | …每帧实际呈现 4` (the multiplier you asked for)
- `ReShade.log` → `NR-VERDICT … state=ENGAGED`
- `dlss5-feed.log` → `MV probe … mean |mv|` reads tens of px while you move

---

## Main features

- **Real frame generation, 1x–6x.** `mfg_frames` selects 2x / 3x / 4x / 5x / 6x. Verified: ~160 fps
  on screen = ~40 fps application-side at 2560x1600 with native iSize.
- **DLSS / DLAA upscaling and DLSS 5 neural rendering**, both fed by the engine's real TAA motion
  vectors (`FO4ReShadeHelper` → `fs4mfg_mvfeed.fx` → the feed's guide chain). One writer, constant
  units, no double-peak.
- **The UI stays pixel-exact (`ui_exact`, on by default).** The HUD, subtitles and dynamic bars are
  lifted out before the DLAA pass and composited back afterwards, so they keep their original pixels
  while the world still gets the upscaler. Turn it off with `ui_exact=0`.
- **Real depth and real camera.** The game's own D24S8 depth buffer is converted to R32_FLOAT, and
  the camera pair comes from the engine's own previous-frame pose rather than an estimated one.
- **Works with renodx-dlss5 8.5.** That version's neural rendering refuses every frame unless its
  internal compute-state shadow lands on the right command-list world; `start_after_presents=150`
  in `fs4mfg.ini` is what makes it land correctly. Do not lower it.
- **Performance headroom.** Neural rendering is the one big cost (~22–28 ms/frame, 40–65% of the
  frame). NR's own "Faster" option (`NRResolutionScale=0.5`) cuts that to ~7 ms.
- **One-click off, separate log, on-screen frame counter** (`stats_window=1`).
- **Cleaned-up shader chain.** The LumeniteFX Kernel pre-pass is replaced by a stub, because this
  mod overwrites the flow texture it produces every frame — the original file ships next to it as
  `lumenite_Kernel.fx.original` if you want it back.

---

## Requirements

| | |
| --- | --- |
| Game | Fallout 4 **v1.10.163** (F4SE 0.6.23 + ENB 0.496) **or v1.11.240** (F4SE 0.7.9 + ENB 0.501) — both tested |
| Mod manager | Optional. Mod Organizer 2 (copy into `overwrite\Root`) **or** no manager at all — run `install.bat`. **ENB is required** and is not bundled |
| GPU | **NVIDIA RTX 40-series or newer** — DLSS-G will not load on anything older. Developed and verified on an RTX 5060 Laptop |
| Driver | No hard minimum. The bundled `nvngx_dlssnr.dll` declares "minimum driver 615.00" in its log line, but that is a declaration only — 581.15 runs it fine |
| ReShade | 6.8 — bundled as `dxgi.dll` |
| OS | Windows 10 / 11, 64-bit |
| Must be off | **NVIDIA Smooth Motion** (and any other frame-generation tool) |

---

## Shout outs

- **crosire** — ReShade, the add-on API this is built on.
- **NVIDIA** — Streamline and the NGX runtimes that make DLSS-G possible.
- **Lecram** — RenoDX DLSS5, the neural-rendering engine this project feeds.
- **The dlss5-feed / dlss5-lab-overlay authors** — the upscaler and guide bridge.
- **Afzaal** — LumeniteFX Kernel (shipped here, with its pre-pass stubbed out — the original is
  included as `lumenite_Kernel.fx.original`).
- **Vortigern** — VORT motion tools (MIT).
- **The Fallout New Vegas ReShade helper project** — the add-on-side buffer-publishing pattern
  that `FO4ReShadeHelper` was modelled on.

All third-party components remain under their authors' own terms. Please ask before re-uploading
or bundling this mod.

---

# 中文版

## Description（简介）

《辐射4》既没有 DLSS 也没有帧生成。这个 mod 把两样都给它，而且是**真**的。

它在游戏窗口上自建一条 D3D12 交换链，自己驱动 NVIDIA Streamline / DLSS-G，于是游戏在
**完全不支持 DLSS** 的情况下拿到了真正的多帧生成（2× / 4× / 6×）—— 中间帧是驱动级帧生成器
产出的，不是后处理滤镜糊出来的。

同时把 DLSS 5 接进同一条链：DLSS / DLAA 上采样与神经渲染由 `dlss5-feed` + `renodx-dlss5`
提供，而本 mod 把**引擎真实的 TAA 运动矢量**（直接取自游戏自己的运动缓冲）喂给它们，
而不是让它们去猜光流。光流必须猜；几何矢量不用。实际效果就是快速转身不再抹糊：
实测静止时精确 0 px、转身时数十 px，且没有离群值。

游戏目录里没有任何文件被改动。停用只需双击 `mfg-disable.bat`。

---

## 本版变更（2026-10-04）

- **UI 不再经过 DLAA —— 新增 `ui_exact`，默认开启。**
  以前 feed 的 DLAA 是在**成品帧**（场景 + HUD 一起）上跑的，于是 HUD 带着世界的运动矢量被
  时域重投影、糊掉。现在插件把成品帧 **B** 存下、只把**不含 UI 的场景帧 A** 交给上采样器，
  再把 UI 的逐像素真实贡献合回去：`presented = saturate(DLAA(A) + B − A)`。
  **无掩膜、无阈值、无膨胀、无边缘泄漏** —— 任何 HUD、任何分辨率免适配，半透明 UI 也精确。
  实机验证（自由游玩）：100% 的帧跑完整条链，"场景无 HUD"那一帧在 30 个采样帧里 29 帧识别正确。
- **移除 `hudless_tag=2/3`。** 把真·无 HUD 帧经第二条共享桥喂给 DLSS-G，2026-10-02 实测两次，
  移动和转身都变差。代码已删除；这个键恢复成纯 0/1，写 ≥2 会被钳回 1。
- **ENB 是必需的，但依然不随包附带。** 上一版包里带着作者自己的 ENB（`d3d11.dll` /
  `enbseries.ini` / `enblocal.ini`），这一版仍然不附带 —— 请你自行安装（enbdev.com：
  游戏 1.10.163 用 **0.496**，1.11.x 用 **0.501**）。实测对照（同一套文件、唯一差别是有没有
  ENB）：没有时 `MV probe 0.000 px / 0% 非零`，有时 `非零占比 100%`（数值随转镜头从 0.02
  涨到 20 px）。没 ENB 时接管和 4× 照跑，但 DLSS-G 拿不到运动矢量，插值帧会拖影。
- **新增安装 / 停用 / 还原脚本。** 不用 MO2 也能装：`install.bat` 自动找游戏目录、
  **先备份会被覆盖的文件**再复制进去；`mfg-disable.bat` / `mfg-enable.bat` / `restore.bat`
  分别用来停用、重新启用、彻底卸载。
- **修好辐射 4 的无 HUD 帧抓取点。** FO4 一帧里会**多次**把后缓冲在不带深度的情况下绑定；
  只有**第一次**才是"后处理已完、HUD 还没画"，后面几次拿到的就是成品帧本身。抓取点现在取第一次。
  （天际恰好相反 —— 末次才对，所以同一份代码需要按游戏分别取。）
- **快捷键统一**：F8 开关效果、F7 开关覆盖层、F12 截图（不再需要 Ctrl）。删掉 7 条没用到的绑定。
- **`wire-shot.bat`** 的截图目录改成脚本旁边的 `shots\`，不再是写死的路径。

**已知问题**

- 上采样器 guide 链的几何掩膜仍然必需 —— **不要把 `GEOM_ENABLE` 改成 0**；关掉之后 guide 链会
  相信那些本来不成立的运动矢量，字幕实测立刻变糊。
- **生成帧**里的 HUD 仍会被一起插值（那是 DLSS-G 自己的 HUD 处理）。`ui_exact` 解决的是 DLAA
  造成的发糊，不是插帧。
- 搬运偶发毫秒级卡顿，喂帧插件内偶发数百毫秒级单帧，原因仍在查。

## Installation instructions（安装）

先装好 **Fallout 4 v1.10.163**（或 **v1.11.240**）+ **对应版本的 F4SE**（1.10.163 → 0.6.23，
1.11.240 → 0.7.9）+ **ENB**（分别 0.496 / 0.501），然后在下面两条路里**选一条**：

**A. 不用模组管理器（推荐，脚本会帮你备份）**

1. 把压缩包解到一个**游戏目录之外**的地方（桌面就行）；
2. 双击 **`install.bat`**；
3. 它会找到游戏目录、把会被覆盖的文件先备份到 `MFG-backup-<时间戳>\`，再复制进去。
   找不到就把你的辐射4 目录拖到 `install.bat` 上。

**B. 用 Mod Organizer 2**

把压缩包里的**全部内容**复制进你的 MO2 `overwrite\Root`（也就是游戏根目录）。
这条路上那些脚本会被忽略，留在压缩包里就行。

**两条路都要收尾：**

4. 把 `Data\F4SE\Plugins\fs4mvcam.dll` 复制到 `<游戏目录>\Data\F4SE\Plugins\`
   （A 路已自动完成；B 路需要手动）。这个插件负责发布引擎的相机位姿与上一帧位姿。
5. **关闭 NVIDIA Smooth Motion**（NVIDIA app / 控制面板）。它本身也是插帧，两个一起开会互相打架。
6. 启动游戏。

**本包不含 ENB，但 ENB 是必需的**：请自行安装（这是运动矢量的前提）。你已经装好的 ENB
不会被本包动。

**日志。** `fs4mfg.ini` 里的 `log_path` 默认为空，`fs4mfg.log` 会写在插件旁边。
若你的管理器虚拟文件系统干扰写盘，把 `log_path` 指到游戏目录之外，例如
`log_path=D:\MFG-log\fs4mfg.log`。

| 想做的事 | 双击 |
| --- | --- |
| 暂时不要这一层（随时能开回来） | `mfg-disable.bat` |
| 开回来 | `mfg-enable.bat` |
| 彻底卸载：把备份的原文件放回去、删掉本包新增的文件 | `restore.bat` |

`mfg-disable.bat` 只是把这一层的入口文件（`dxgi.dll`、`fs4mfg.addon64`、`dlss5-feed.addon64`、
`renodx-dlss5.addon64`、`FO4ReShadeHelper.addon64`）改名成 `.off`，不删任何东西，游戏立刻回到
原本的呈现路径。`fs4mfg.ini` 里 `enabled=0` 也能让它完全不动渲染，且不用改文件名。

**验证是否正常** —— 看三行：

- `fs4mfg.log` → `MFG | …每帧实际呈现 4`（你设的倍数）
- `ReShade.log` → `NR-VERDICT … state=ENGAGED`
- `dlss5-feed.log` → `MV probe … mean |mv|` 移动时有几十 px

## Main features（核心功能）

- **真正的帧生成，1×–6×。** `mfg_frames` 选择 2× / 3× / 4× / 5× / 6×。实测：2560×1600、
  iSize 原生下，屏幕约 160 fps = 应用侧约 40 fps × 4。
- **DLSS / DLAA 上采样 + DLSS 5 神经渲染**，两者都由引擎真矢量驱动
  （`FO4ReShadeHelper` → `fs4mfg_mvfeed.fx` → feed 的 guide 链）。单写者、恒定单位、无双峰。
- **UI 保持原像素（`ui_exact`，默认开）。** HUD、字幕与动态数据条在进 DLAA 之前就被摘出来、
  之后原样合回，于是它们保持自己的像素，而风景照旧吃上采样。关掉用 `ui_exact=0`。
- **真深度 + 真相机。** 游戏自己的 D24S8 深度转成 R32_FLOAT；相机对来自引擎自己的上一帧位姿，
  不是估出来的。
- **与 renodx-dlss5 8.5 兼容。** 8.5 的神经渲染要求它的 compute-state 影子落在正确的
  命令列表世界，否则每一帧都会被拒。`fs4mfg.ini` 里的 `start_after_presents=150` 就是干这个的，
  **不要调小**。
- **性能余量。** 唯一的大开销是神经渲染（约 22–28 ms/帧，占整帧 40–65%）。
  用 NR 自带的 "Faster"（`NRResolutionScale=0.5`）可降到约 7 ms。
- **一键停用、独立日志、屏上帧数读数**（`stats_window=1`）。
- **清理过的着色器链。** LumeniteFX Kernel 的前置 pass 已被 stub 替换，因为本 mod 每帧都会
  覆盖它产出的光流纹理；原文件以 `lumenite_Kernel.fx.original` 随包提供，随时可还原。

## Requirements（需求）

| | |
| --- | --- |
| 游戏 | Fallout 4 **v1.10.163**（F4SE 0.6.23 + ENB 0.496）**或 v1.11.240**（F4SE 0.7.9 + ENB 0.501）——两个都实测可用 |
| 管理器 | 可选。Mod Organizer 2（复制进 `overwrite\Root`）**或者**干脆不用管理器 —— 双击 `install.bat`。**必须装 ENB**，本包不含 ENB |
| 显卡 | **NVIDIA RTX 40 系或更新** —— 更老的卡 DLSS-G 根本不会加载。本 mod 在 RTX 5060 Laptop 上开发与验证 |
| 驱动 | 无硬性下限。包内 `nvngx_dlssnr.dll` 的日志会打印 "minimum driver 615.00"，但那是**声明** —— 实测 581.15 也能正常跑 |
| ReShade | 6.8（本包自带 `dxgi.dll`） |
| 系统 | Windows 10 / 11 64 位 |
| 必须关闭 | **NVIDIA Smooth Motion**（以及其它任何插帧工具） |

## Shout outs（致谢）

- **crosire** —— ReShade，本项目的立足点。
- **NVIDIA** —— Streamline 与 NGX 运行时，帧生成的前提。
- **Lecram** —— RenoDX DLSS5，本项目所驱动的神经渲染引擎。
- **dlss5-feed / dlss5-lab-overlay 的作者** —— 上采样与 guide 桥接。
- **Afzaal** —— LumeniteFX Kernel（随包提供，前置 pass 已 stub；原文件以
  `lumenite_Kernel.fx.original` 一并包含）。
- **Vortigern** —— VORT 运动工具（MIT）。
- **辐射：新维加斯的 ReShade helper 项目** —— `FO4ReShadeHelper` 的"插件侧发布缓冲"思路参照了它。

所有第三方组件遵循各自作者的授权。二次分发或整合包请先取得同意。
