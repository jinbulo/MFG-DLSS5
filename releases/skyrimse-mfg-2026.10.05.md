# SkyrimSE MFG — 2026-10-05

Real multi-frame generation (DLSS-G) + DLSS 5 neural rendering for **Skyrim Special
Edition**, on top of an existing ENB setup, without touching it.

**Package:** `SkyrimSE-MFG-2026-10-05.zip` (154.9 MB, 46 entries)
**SHA-256:** `28066A52AE69A68592ED352AF4F9F7EAC27A2F0CE4DD3863681AC1D664971642`
**Nexus page:** https://www.nexusmods.com/skyrimspecialedition/mods/194020

## Verified builds

| Game | Script extender | ENB |
| --- | --- | --- |
| Skyrim SE **1.5.97** | SKSE64 **2.0.20** | ENB **0.505** |
| Skyrim SE **1.7.104 (AE)** | SKSE64 **2.3.1** | ENB **0.505** |

1.5.97 is the longest-validated baseline (takeover, 4x, `ui_exact`, and both motion-vector
paths). 1.7.104 was verified too: takeover OK, 4x (21 → 85 fps on screen), motion vectors
100% non-zero (mean |mv| 7.56 px). On AE the motion vectors come from the engine buffer via
ENB — the mod's own camera-matrix fallback path stays 1.5.97-calibrated and does not engage
there. Other builds are untested; install the ENB and SKSE64 that match your build and try it.

ENB is **mandatory** — measured with the same files and the same add-on, only ENB added:
motion probe `0.000 px, 0% non-zero` without it → `100% non-zero` with it. ENB is **not**
bundled (redistribution is not permitted by its author); get it from https://enbdev.com/.

## Install

1. Install the game, the matching SKSE64, and ENB 0.505. Set `EnableFPSLimit=false` in
   `enblocal.ini`.
2. Extract this archive **outside** the game folder and run `install.bat`. It finds the game,
   checks `SkyrimSE.exe`'s version first (anything that is not 1.5.97 warns and requires you
   to type `yes`), backs up every file it overwrites, and copies the mod in.
   (MO2 users: copy the archive contents into `overwrite\Root`.)
3. Set the game to **borderless windowed** — MO2 users must change it in the *profile's*
   `skyrimprefs.ini`, not the one in Documents — turn **NVIDIA Smooth Motion** off, keep
   `ENBFrameGeneration.dll` disabled, and launch through `skse64_loader.exe` or the bundled
   `launch-skse.bat`. Starting from Steam works too, as long as Steam actually runs the SKSE
   loader and does not update the game to a build your SKSE64 does not match.

This mod deliberately ships **no** `Data\SKSE\Plugins` plugin — a missing .dll there is by
design, not a broken install.

## Highlights in this build

- Bilingual installer that finds the game itself (drag & drop → script folder → last path →
  Bethesda registry → **every Steam library**, including a second drive), with a version gate,
  automatic elevation for protected folders, and a backup of everything it overwrites.
- New `launch-skse.bat`; the status report also tells you whether the script extender is
  present.
- `ReShade.ini` fixed: screenshot key is **F10**, screenshots go to the **game root**, and the
  author's local paths are gone.
- **ENB is now correctly documented as mandatory** (the earlier "ENB optional" wording was
  wrong and has been removed everywhere).
- AE (1.7.104) support verified, plus a bundled `DOWNGRADE-to-1.5.97.md` with the complete
  Steam console recipe.

`ui_exact` is on by default, so the HUD, compass and subtitles are not run through DLAA;
turn it off with `ui_exact=0` to compare. `hudless_tag` accepts only `0/1`.

Full documentation is in the archive (`README.md`, `更新说明.md`,
`DOWNGRADE-to-1.5.97.md`); copies are also in [`docs/`](../docs).

---

## 中文

《上古卷轴5 特别版》真多帧生成 + DLSS 5 神经渲染。实测通过：**1.5.97 + SKSE64 2.0.20 + ENB 0.505**
（验证最久的基线）与 **1.7.104 (AE) + SKSE64 2.3.1 + ENB 0.505**（接管成功、4×、运动矢量 100% 非零）。
两者都必须无边框窗口。**ENB 必需但不随包提供**，请自行到 enbdev.com 下载；其它版本未测试，
装好对应版本的 ENB 与 SKSE64 后可自行尝试。

安装：解压到游戏目录之外 → 双击 `install.bat`（非 1.5.97 会警告并要求输入 yes）。
用 MO2 的话把内容复制进 `overwrite\Root`，并且无边框要在 **profile 的** `skyrimprefs.ini` 里改。
启动用 `skse64_loader.exe` 或包里的 `launch-skse.bat`；从 Steam 直接启动也可以，
只要 Steam 实际拉起的是 SKSE 的 loader，并且别让 Steam 把版本更新掉。
