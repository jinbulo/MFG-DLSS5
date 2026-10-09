# Third-party components and credits

The `FS4-MFG-*.zip` and `SkyrimSE-MFG-*.zip` packages contain files authored by other
people and projects. They are redistributed **unchanged**, under their own authors' terms.
Nothing here transfers any rights to those components, and nothing here overrides the terms
published by their authors.

## Included in both packages

| Component | What it is | Author / project | Terms |
| --- | --- | --- | --- |
| **ReShade 6.8** (`dxgi.dll`) | The add-on host; loads every `.addon64` module. The archives ship ReShade itself so the mod works out of the box. | crosire — https://reshade.me | See the ReShade project's own licence and redistribution terms. |
| **NVIDIA Streamline** (`sl.common.dll`, `sl.dlss_g.dll`, `sl.interposer.dll`, `sl.nvperf.dll`, `sl.pcl.dll`, `sl.reflex.dll`) | Frame-generation / latency runtime. | NVIDIA | NVIDIA Streamline redistribution terms (NVIDIA developer licence for the SDK). |
| **NVIDIA NGX runtimes** (`nvngx_dlss.dll`, `nvngx_dlssg.dll`, `nvngx_dlssnr.dll`) | DLSS / DLSS-G / DLSS neural-rendering runtime libraries. | NVIDIA | NVIDIA NGX / DLSS SDK redistribution terms. |
| **dlss5-feed** (`dlss5-feed.addon64`, `dlss5-feed.cfg`, `DLSS5-Feeder.ini`) | DLSS 5 feeding / guide bridge. | The dlss5-feed authors | See the project's own terms. |
| **dlss5-lab-overlay** (`dlss5-lab-overlay.addon64`, FS4 package only) | Diagnostic overlay used while validating the chain. | The dlss5-lab-overlay authors | See the project's own terms. |
| **RenoDX DLSS5** (`renodx-dlss5.addon64`) | Neural-rendering engine the mod feeds. | Lecram / the RenoDX project | See the RenoDX project's own terms. |
| **LumeniteFX Kernel** (`lumenite_Kernel.fx`, `lumenite_Kernel.fx.original`, related `lumenite_*.fx`) | Shader pack. The pre-pass is stubbed in these packages because the mod overwrites the flow texture it produces; the untouched original ships alongside it as `lumenite_Kernel.fx.original`. | Afzaal | See the LumeniteFX distribution terms. |
| **VORT motion tools** (`vort_*.fx`, `vort_*.fxh`, `vort_BlueNoise.png`, `vort_MLUT.png`) | Motion-vector / colour tooling used by the shader chain. | Vortigern | MIT. |
| **DirectX 12 Agility SDK** (`D3D12Core.dll`, `sysd3d12.dll`, `sysdxgi.dll`) | D3D12 runtime files needed for the layer's own swapchain. | Microsoft | Microsoft licence for the DirectX 12 Agility SDK / Windows SDK redistributables. |
| **WinPixEventRuntime.dll** | GPU event-marker runtime. | Microsoft (PIX) | Microsoft redistributable terms. |
| **FO4ReShadeHelper** (`FO4ReShadeHelper.addon64`, `FO4ReShadeHelper.ini`) | Publishes the engine's motion-vector, depth and camera buffers into ReShade. Written for this project; the buffer-publishing approach follows the Fallout New Vegas ReShade helper project. | This project | Part of the mod (see `LICENSE.md`). |

## NOT included — the user installs these

| Component | Why it is not bundled |
| --- | --- |
| **ENB** (Boris Vorontsov, https://enbdev.com/) | Redistribution of ENB binaries is not permitted by its author. ENB is **required** by both mods, so download it yourself and install it into the game folder. These packages never contain or overwrite `d3d11.dll`, `enbseries.ini` or `enblocal.ini`. |
| **SKSE64** (https://skse.silverlock.org/) | Installed by the user; must match the game build (2.0.20 for 1.5.97, 2.3.1 for 1.7.104). |
| **F4SE** (https://f4se.silverlock.org/) | Installed by the user; must match the game build (0.6.23 for 1.10.163, 0.7.9 for 1.11.240). |
| Game data, ENB presets, textures | Not part of these mods. |

## Written for this project

`fs4mfg.addon64`, `SkyrimMFG.addon64`, `FO4ReShadeHelper.addon64`,
`fs4mfg_mv.fx` / `fs4mfg_mvfeed.fx`, `motion_vector.fx`, the installer scripts
(`install.bat`, `mfg-disable.bat`, `mfg-enable.bat`, `restore.bat`, `mfg-tool.ps1`,
`launch-f4se.bat`, `launch-skse.bat`, `wire-shot.bat`, `measure-fps.bat`),
`fpscount.exe`, `frameshot.exe`, `fs4mvcam.dll`, the INI files and the documentation were
written by the author of these mods. See `LICENSE.md`.

## Credits

With thanks to: **crosire** (ReShade), **Boris Vorontsov** (ENB), **NVIDIA** (Streamline,
NGX, DLSS-G), **Lecram** (RenoDX DLSS5), the **dlss5-feed / dlss5-lab-overlay authors**,
**Afzaal** (LumeniteFX Kernel), **Vortigern** (VORT motion tools, MIT),
**doodlum (StreamlineForENB) and the Community Shaders team** (the "hook the engine's
motion-vector render target" approach), the **Fallout New Vegas ReShade helper project**
(the add-on buffer-publishing pattern), and the **SKSE and F4SE teams**.

If you are one of these authors and want a component removed from these packages, or want
the attribution changed, open an issue or contact the mod author and it will be handled.
