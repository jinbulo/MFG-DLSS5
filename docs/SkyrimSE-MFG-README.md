# SkyrimSE MFG — Real Frame Generation + DLSS 5 Neural Rendering

---

**Description**

Skyrim Special Edition has neither DLSS nor frame generation. This mod adds both, on top of your
existing **ENB** setup, without touching it.

It takes the window over with its own D3D12 flip swapchain and drives NVIDIA Streamline / DLSS-G
itself, so the game gets genuine multi-frame generation (2x / 3x / 4x / 5x / 6x). The intermediate
frames come from the driver's frame generator, not from a post-process filter.

Upscaling and DLSS 5 neural rendering come from `dlss5-feed` + `renodx-dlss5`, and this mod feeds
both of them the **engine's own TAA motion vectors** — published straight out of the game's motion
buffer by `FO4ReShadeHelper` — instead of optical flow. It also hands over the game's real depth
buffer and the engine's own camera pair, so neither the upscaler nor the frame generator has to
guess anything. In practice: motion reads exactly 0 px while you stand still and tens of px while
you turn, with no outliers.

The UI is handled too: **`ui_exact`** lifts the HUD, compass and subtitles out before DLAA runs and
composites them back afterwards, so they keep their original pixels while the world still gets
DLAA. No mask, no threshold — any HUD, any resolution, translucency included.

---

**Installation instructions**

0. Skyrim SE **1.5.97** + **SKSE64**, with **ENB already installed** (ENB 0.505 from enbdev —
   it is what makes the engine publish the motion vectors this mod feeds to DLSS-G).

   Measured, same add-on both times, only ENB added:

   | | no ENB | with ENB 0.505 |
   | --- | --- | --- |
   | takeover / 4x frame gen | works | works |
   | motion-vector feed | `0.000 px, 0% non-zero` | `100% non-zero`, `mean \|mv\| 7.56 px` |

   Without ENB the chain still runs, but the generated frames have no motion data and will smear
   when you move the camera. This pack adds `dxgi.dll` (ReShade 6.8) and the add-ons only; it
   never ships or overwrites ENB's `d3d11.dll`, `enbseries.ini` or `enblocal.ini`, and it does not
   touch your `Data\` folder.

Then pick **one** of the two paths:

**A. No mod manager (the pack backs things up for you)**

1. Extract this archive to a folder **outside** your game folder (the Desktop is fine).
2. Run **`install.bat`**.
3. It finds your game folder, backs up every file it is about to overwrite into
   `MFG-backup-<timestamp>\`, and copies the mod in. If it cannot find the game, drag your
   Skyrim SE folder onto `install.bat`.

**B. Mod Organizer 2**

Copy everything in this archive into your Skyrim SE game root. The scripts are ignored in this
path — you can leave them in the archive.

**Both paths, finish with:**

4. **Turn NVIDIA Smooth Motion off** (NVIDIA app / control panel). It is frame generation too, and
   the two will fight each other.
5. Make sure no other frame-generation tool is active — in particular **`ENBFrameGeneration.dll`
   must stay disabled** in your mod manager (two layers taking the window over is one too many).
6. Launch the game through MO2 / SKSE.

The layer takes the window over a moment after the DLSS feed is ready; `SkyrimMFG.log` shows it as
`TAKEOVER | 到达接管点 ...`. A small on-screen frame counter is on by default — `stats_window=0`
hides it, and `enabled=0` makes the whole layer passive without moving any file.

| What you want | Run |
| --- | --- |
| Turn the layer off for now (fully reversible) | `mfg-disable.bat` |
| Turn it back on | `mfg-enable.bat` |
| Uninstall — put the backed-up originals back and delete what this pack added | `restore.bat` |

`mfg-disable.bat` only renames the layer's entry points (`dxgi.dll`, `SkyrimMFG.addon64`,
`dlss5-feed.addon64`, `renodx-dlss5.addon64`, `FO4ReShadeHelper.addon64`) to `.off`; nothing is
deleted, your ENB keeps running, and the game immediately returns to its normal present path.

---

**Main features**

- **Real frame generation, 1x–6x.** `mfg_frames` selects 2x / 3x / 4x / 5x / 6x. Verified in game:
  ~90–108 fps on screen against ~23–27 fps application-side at 2560x1600 (4x).
- **Real motion vectors.** The engine's TAA motion buffer (R16G16_FLOAT) is published into
  ReShade's `MOTION_VECTOR` by `FO4ReShadeHelper` and handed to DLSS-G and to the neural renderer.
  One writer, constant units, no double-peak.
- **Real depth and real camera.** The game's own depth buffer is converted to R32_FLOAT; the camera
  pair comes from the engine's previous-frame world matrix, not from a guessed pose.
- **DLSS 5 neural rendering** through `renodx-dlss5` 8.5, wired so its compute-state shadow lands on
  the right command-list world (`wait_dlss_feed=1`).
- **The UI stays pixel-exact (`ui_exact`).** First release shipping it on by default; the HUD and
  subtitles are not run through DLAA. Turn it off with `ui_exact=0`.
- **Verified end to end:** in a full session the whole path ran on 100 % of frames
  (`UIEXACT | 累计: 帧 4183，有A 4183，改写 4183，合成 4183`), MFG reported 4x actual = 4x
  requested, `NR-VERDICT state=ENGAGED ratio=0.9993`, and the log held zero errors.
- **One-line off, separate log, on-screen frame counter** (`stats_window=1`).

---

**Requirements**

| | |
| --- | --- |
| Game | Skyrim Special Edition **1.5.97** (tested), SKSE64, MO2 |
| Host | **ENB required** — install ENB 0.505 for Skyrim SE (enbdev.com) yourself; not bundled. ReShade `dxgi.dll` is bundled |
| GPU | **NVIDIA RTX 40-series or newer** — DLSS-G will not load on anything older |
| Driver | No hard minimum. Tested on a laptop RTX 5060 (8 GB) |
| ReShade | 6.8 — bundled as `dxgi.dll` |
| OS | Windows 10 / 11, 64-bit |
| Must be off | **NVIDIA Smooth Motion**, and any other frame-generation tool |

**Two numbers that must match your game.** The camera model uses a horizontal FOV of 77°
(`cam_fov_deg=77`) and Skyrim's default near plane of 15 units. If you changed your field of view,
set `cam_fov_deg` to your actual horizontal FOV — the log prints an `FOV 判据` line that helps you
pin it down from an in-place turn frame. If your frame generation looks "off" or motion smears,
that value is the first thing to check.

**Performance.** Neural rendering is the one big cost (~24 ms per frame, 38–45 % of the frame). If
your application-side frame rate drops below ~15 fps, either raise `mfg_frames` down to 2 (3x) or
set `NRResolutionScale=0.5` in `ReShade.ini` (that takes neural rendering down to roughly 7 ms).
On an 8 GB card the full setup also sits near the VRAM limit at 2560x1600.

---

**Shout outs**

- **crosire** — ReShade, the add-on API this is built on.
- **Boris Vorontsov** — ENB, which this mod uses as its display host.
- **NVIDIA** — Streamline and the NGX runtimes that make DLSS-G possible.
- **Lecram** — RenoDX DLSS5, the neural-rendering engine this project feeds.
- **The dlss5-feed / dlss5-lab-overlay authors** — the upscaler and guide bridge.
- **Afzaal** — LumeniteFX Kernel (shipped here with its pre-pass stubbed out; the original file is
  included next to it as `lumenite_Kernel.fx.original`).
- **Vortigern** — VORT motion tools (MIT).
- **doodlum (StreamlineForENB) and the Community Shaders team** — the "hook the engine's motion
  vector render target" idea that this mod's motion-vector path is modelled on.

All third-party components remain under their authors' own terms. Please ask before re-uploading or
bundling this mod.

---

# 中文版

**Description（简介）**

《上古卷轴5 特别版》既没有 DLSS 也没有帧生成。这个 mod 在你**现有 ENB 之上**把两样都加上，
而且不改动你的 ENB。

它在游戏窗口上自建一条 D3D12 交换链，自己驱动 NVIDIA Streamline / DLSS-G，于是游戏在完全不
支持 DLSS 的情况下拿到了真正的多帧生成（2× / 3× / 4× / 5× / 6×）—— 中间帧是驱动级帧生成器
产出的，不是后处理滤镜糊出来的。

DLSS / DLAA 上采样与 DLSS 5 神经渲染由 `dlss5-feed` + `renodx-dlss5` 提供，而本 mod 把
**引擎真实的 TAA 运动矢量**（由 `FO4ReShadeHelper` 直接从游戏自己的运动缓冲发布）喂给它们，
而不是让它们去猜光流；同时把游戏真实的深度缓冲与引擎自己的相机位姿一并交出去，上采样器和
帧生成器都不需要猜。实际效果：静止时运动量精确为 0 px，转身时数十 px，没有离群值。

UI 也做了处理：**`ui_exact`** 在 DLAA 之前把 HUD、罗盘和字幕摘出来、之后原样合回，于是它们保持
自己的像素，而风景照旧吃 DLAA。没有掩膜、没有阈值 —— 任何 HUD、任何分辨率、半透明也精确。

**Installation instructions（安装）**

0. Skyrim SE **1.5.97** + **SKSE64**，并且 **ENB 已经装好**（enbdev 的 ENB 0.505）——
   运动矢量就是靠 ENB 在场才出来的。

   实测对照（同一支 addon，唯一差别是有没有 ENB）：

   | | 没装 ENB | 装了 ENB 0.505 |
   | --- | --- | --- |
   | 接管 / 4 倍帧生成 | 正常 | 正常 |
   | 运动矢量 | `0.000 px，0% 非零` | `非零占比 100%`，`mean \|mv\| 7.56 px` |

   没 ENB 时链路照跑，但插值帧拿不到运动信息，转镜头会拖影。本包只新增 `dxgi.dll`
   （ReShade 6.8）与各 addon，**不包含也不覆盖** ENB 的 `d3d11.dll`、`enbseries.ini`、
   `enblocal.ini`，也不动你的 `Data\`。

然后在下面两条路里**选一条**：

**A. 不用模组管理器（脚本会帮你备份）**

1. 把压缩包解到一个**游戏目录之外**的地方（桌面就行）；
2. 双击 **`install.bat`**；
3. 它会找到游戏目录、把会被覆盖的文件先备份到 `MFG-backup-<时间戳>\`，再复制进去。
   找不到就把你的天际目录拖到 `install.bat` 上。

**B. 用 Mod Organizer 2**

把压缩包里的全部内容复制进你的天际游戏根目录。这条路上那些脚本会被忽略，留在压缩包里就行。

**两条路都要收尾：**

4. **关闭 NVIDIA Smooth Motion**（NVIDIA app / 控制面板）—— 它本身也是插帧，两个一起开会打架。
5. 确认没有别的插帧工具在跑 —— 特别是 mod 管理器里的 **`ENBFrameGeneration.dll` 必须保持禁用**
   （两个东西同时抢窗口是灾难）。
6. 用 MO2（SKSE）启动。

层会在 DLSS 喂帧就绪后不久接管窗口，`SkyrimMFG.log` 里会写 `TAKEOVER | 到达接管点 ...`。
屏上帧数读数默认开着：`stats_window=0` 关掉它，`enabled=0` 让整层完全不动渲染（不用改文件名）。

| 想做的事 | 双击 |
| --- | --- |
| 暂时不要这一层（随时能开回来） | `mfg-disable.bat` |
| 开回来 | `mfg-enable.bat` |
| 彻底卸载：把备份的原文件放回去、删掉本包新增的文件 | `restore.bat` |

`mfg-disable.bat` 只是把这一层的入口文件（`dxgi.dll`、`SkyrimMFG.addon64`、`dlss5-feed.addon64`、
`renodx-dlss5.addon64`、`FO4ReShadeHelper.addon64`）改名成 `.off`，不删任何东西，你的 ENB 照常运行，
游戏立刻回到原本的呈现路径。

**Main features（核心功能）**

- **真正的帧生成，1×–6×。** `mfg_frames` 选择 2× / 3× / 4× / 5× / 6×。实机验证：2560×1600 下
  屏幕约 90–108 fps、应用侧约 23–27 fps（4×）。
- **真运动矢量。** 引擎 TAA 运动缓冲（R16G16_FLOAT）由 `FO4ReShadeHelper` 发布进 ReShade 的
  `MOTION_VECTOR`，再交给 DLSS-G 与神经渲染。单写者、恒定单位、无双峰。
- **真深度 + 真相机。** 游戏自己的深度缓冲转成 R32_FLOAT；相机对来自引擎自己的上一帧世界矩阵。
- **DLSS 5 神经渲染**，接的是 `renodx-dlss5` 8.5，并用 `wait_dlss_feed=1` 把它的 compute-state
  影子放到正确的命令列表世界上。
- **UI 保持原像素（`ui_exact`，本版首次默认开启）。** HUD 与字幕不再经过 DLAA；关掉用 `ui_exact=0`。
- **整链实测**：一局里 100% 的帧跑完整条链（`UIEXACT | 累计: 帧 4183，有A 4183，改写 4183，合成 4183`），
  MFG 实测倍数 = 自报倍数 = 4×，`NR-VERDICT state=ENGAGED ratio=0.9993`，日志零错误。
- **一行停用、独立日志、屏上帧数读数**（`stats_window=1`）。

**Requirements（需求）**

| | |
| --- | --- |
| 游戏 | Skyrim SE **1.5.97**（实测）、SKSE64、MO2 |
| 宿主 | **必须装 ENB** —— 自行安装 Skyrim SE 的 ENB 0.505（enbdev.com），本包不含；ReShade `dxgi.dll` 本包自带 |
| 显卡 | **NVIDIA RTX 40 系或更新** —— 更老的卡 DLSS-G 根本不会加载 |
| 驱动 | 无硬性下限；实测平台是笔记本 RTX 5060（8 GB） |
| ReShade | 6.8（本包自带 `dxgi.dll`） |
| 系统 | Windows 10 / 11 64 位 |
| 必须关闭 | **NVIDIA Smooth Motion**，以及其它任何插帧工具 |

**两个必须与你游戏一致的数字。** 相机模型按水平 FOV 77°（`cam_fov_deg=77`）与天际默认近平面
15 单位工作。**如果你改过视野，请把 `cam_fov_deg` 改成你的实际水平 FOV** —— 日志里的
`FOV 判据` 行会帮你从"原地转身"的那种帧里反推。插帧看着不对、运动发糊时，先查这个值。

**性能。** 唯一的大开销是神经渲染（约 24 ms/帧，占整帧 38–45%）。若应用侧掉到约 15 fps 以下，
把 `mfg_frames` 降到 2（3×），或在 `ReShade.ini` 里把 `NRResolutionScale` 设成 `0.5`
（神经渲染降到约 7 ms）。8 GB 显存的卡在 2560×1600 下会贴近显存上限。

**Shout outs（致谢）**

- **crosire** —— ReShade，本项目的立足点。
- **Boris Vorontsov** —— ENB，本 mod 的显示宿主。
- **NVIDIA** —— Streamline 与 NGX 运行时，帧生成的前提。
- **Lecram** —— RenoDX DLSS5，本项目所驱动的神经渲染引擎。
- **dlss5-feed / dlss5-lab-overlay 的作者** —— 上采样与 guide 桥接。
- **Afzaal** —— LumeniteFX Kernel（随包提供，前置 pass 已 stub；原文件以
  `lumenite_Kernel.fx.original` 一并包含）。
- **Vortigern** —— VORT 运动工具（MIT）。
- **doodlum（StreamlineForENB）与 Community Shaders 团队** —— "直接挂引擎运动矢量渲染目标"
  这个思路的出处，本 mod 的运动矢量通路参照了它。

所有第三方组件遵循各自作者的授权。二次分发或整合包请先取得同意。
