# FS4 MFG / SkyrimSE MFG — release mirror

Real multi-frame generation (DLSS-G) plus DLSS 5 neural rendering for **Fallout 4** and
**Skyrim Special Edition** — added on top of an existing ENB setup, without touching it.

This repository is the **official download mirror** for the two mods. The primary pages are
on Nexus Mods; while those uploads are under review, the complete packages are published
here as GitHub Releases. When the Nexus pages are live again, both stay in sync — the files
are byte-identical.

| Mod | Direct download | Nexus page |
| --- | --- | --- |
| **FS4 MFG** — Fallout 4 | [FS4-MFG-2026-10-05.zip](https://github.com/jinbulo/MFG-DLSS5/releases/download/fs4-mfg-2026.10.05/FS4-MFG-2026-10-05.zip) · [release notes](https://github.com/jinbulo/MFG-DLSS5/releases/tag/fs4-mfg-2026.10.05) | https://www.nexusmods.com/fallout4/mods/109634 |
| **SkyrimSE MFG** — Skyrim SE | [SkyrimSE-MFG-2026-10-05.zip](https://github.com/jinbulo/MFG-DLSS5/releases/download/skyrimse-mfg-2026.10.05/SkyrimSE-MFG-2026-10-05.zip) · [release notes](https://github.com/jinbulo/MFG-DLSS5/releases/tag/skyrimse-mfg-2026.10.05) | https://www.nexusmods.com/skyrimspecialedition/mods/194020 |

All releases: https://github.com/jinbulo/MFG-DLSS5/releases

---

## Download

Open the [Releases](../../releases) page and pick the build you need.

| Release | Package | Size | SHA-256 |
| --- | --- | --- | --- |
| [`fs4-mfg-2026.10.05`](https://github.com/jinbulo/MFG-DLSS5/releases/tag/fs4-mfg-2026.10.05) | `FS4-MFG-2026-10-05.zip` | 159.6 MB | `45EA045806B1648B6538B3A37C61337E2DB259FB8DBF7566FC78D11CFF9EAB29` |
| [`skyrimse-mfg-2026.10.05`](https://github.com/jinbulo/MFG-DLSS5/releases/tag/skyrimse-mfg-2026.10.05) | `SkyrimSE-MFG-2026-10-05.zip` | 154.9 MB | `28066A52AE69A68592ED352AF4F9F7EAC27A2F0CE4DD3863681AC1D664971642` |

The same hash is printed in each release's description and inside the archive as
`RELEASE-MANIFEST.txt`. Every file inside both archives also has its own SHA-256 there.

Extract the archive somewhere **outside** your game folder and run `install.bat` — it finds
the game, backs up everything it overwrites, and copies the mod in.

---

## What these mods do

Both games ship without DLSS and without frame generation. These mods build their own D3D12
flip swapchain over the game's window and drive **NVIDIA Streamline / DLSS-G** directly, so
the game gets genuine multi-frame generation (2x / 3x / 4x / 5x / 6x) with the in-between
frames coming from the driver's frame generator — not from a post-process filter.

DLAA upscaling and **DLSS 5 neural rendering** come from `dlss5-feed` + `renodx-dlss5`, fed
by the engine's real TAA motion vectors (published through `FO4ReShadeHelper`) instead of
estimated optical flow, with the game's real depth buffer and the engine's own camera pair.
Motion reads exactly 0 px while standing still and tens of px while turning, with no outliers.

`ui_exact` lifts the HUD, subtitles and compass out before the DLAA pass and composites them
back afterwards, so the UI keeps its original pixels while the world is upscaled.

---

## Requirements (short version)

| | Fallout 4 | Skyrim Special Edition |
| --- | --- | --- |
| Game build | 1.10.163 (F4SE 0.6.23) **or** 1.11.240 (F4SE 0.7.9) | 1.5.97 (SKSE64 2.0.20) **or** 1.7.104 AE (SKSE64 2.3.1) |
| ENB | **required** — 0.496 (1.10.163) / 0.501 (1.11.240) | **required** — 0.505 |
| Window mode | **borderless**, always | **borderless**, always |
| GPU | NVIDIA RTX 40-series or newer | NVIDIA RTX 40-series or newer |
| OS | Windows 10 / 11 x64 | Windows 10 / 11 x64 |
| Must be off | NVIDIA Smooth Motion, any other frame-gen layer | same |

**ENB is mandatory** — it is what makes the engine publish the motion vectors the frame
generator consumes. Measured with the same files and the same add-on, only ENB added: motion
probe `0.000 px, 0% non-zero` without it → `100% non-zero` with it. Without ENB the layer
still takes over and produces frames, but they smear when you turn the camera.

**ENB is not bundled** — download it yourself from [enbdev.com](https://enbdev.com/). Redistributing
ENB binaries is not permitted by its author, and these archives never contain or overwrite
`d3d11.dll`, `enbseries.ini` or `enblocal.ini`.

Other game builds are untested rather than blocked: install the ENB and the script extender
that match your build and try it. Support requests are best made on the corresponding Nexus
page (or here in Issues) with the four log files attached: the mod's own log, `dlss5-feed.log`,
`ReShade.log` and `sl.log`.

Full instructions, troubleshooters and the changelog are inside each archive
(`README.md` and `更新说明.md`).

---

## Third-party components

These packages redistribute ReShade, NVIDIA Streamline / NGX runtimes, `dlss5-feed`,
RenoDX DLSS5, LumeniteFX Kernel and VORT motion tools — each under its own author's terms.
See [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md) for the full list and credits.

Neither package is open source and neither is free to re-upload. Please do not mirror,
repackage or bundle these downloads elsewhere; link to this repository or to the Nexus
pages instead.

---

## 中文

本仓库是 **FS4 MFG（辐射4）** 与 **SkyrimSE MFG（上古卷轴5 特别版）** 两个 mod 的官方下载镜像。
Nexus 上的两个页面正在审核中，期间完整安装包在这里以 Release 形式提供；Nexus 恢复后两边内容一致、完全同步。

下载：打开 [Releases](../../releases) 页面，按游戏选择对应压缩包；解压到**游戏目录之外**，
双击 `install.bat` 即可（脚本会自动找游戏、先备份再覆盖）。

三个硬性前提：**必须装 ENB**（自行从 enbdev.com 下载，本包不含）、**必须无边框窗口**、
**关掉 NVIDIA Smooth Motion 等其它插帧工具**。完整说明、排错与更新日志都在压缩包内的
`README.md` 和 `更新说明.md`。

第三方组件（ReShade、NVIDIA Streamline / NGX、dlss5-feed、RenoDX DLSS5、LumeniteFX Kernel、
VORT 运动工具）遵循各自作者的授权，清单见 [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md)。
两个包都不是开源项目，请勿转载、二次打包或整合到其它整合包；需要分享请直接链接本仓库或 Nexus 页面。
