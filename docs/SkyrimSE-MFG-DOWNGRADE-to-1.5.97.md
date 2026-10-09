# Skyrim Special Edition - 降回 1.5.97（Steam 控制台路线）
# Skyrim Special Edition - downgrade back to 1.5.97 (Steam console route)

游戏目录 / Game folder: `D:\Steam\steamapps\common\Skyrim Special Edition`
当前版本 / Current build: **1.7.104**（AE）
目标版本 / Target build: **1.5.97**（本 mod 与 SKSE64 2.0.20 标定的版本）

## 为什么要退 / why

1.7.104 是 AE 版：SKSE 接口、插件地址、以及本层拿相机/运动矢量的那套偏移都跟 1.5.97
不一样。本层按 1.5.97 标定，所以在 AE 上即使接管成功，喂给 DLSS-G 的输入也不对。

## 第 1 步：打开 Steam 控制台 / Step 1: open the Steam console

浏览器地址栏或 Win+R 输入：

    steam://open/console

## 第 2 步：逐条粘贴 / Step 2: paste these three lines

    download_depot 489830 489833 2289561010626853674
    download_depot 489830 489831 7848722008564294070
    download_depot 489830 489832 8702665189575304780

| depot | 内容 / contents | 体积 / size |
| --- | --- | --- |
| 489833 | SkyrimSE.exe + SkyrimSELauncher.exe | ~38 MB |
| 489831 | 游戏数据 a | ~7.5 GB |
| 489832 | 游戏数据 b | ~8.6 GB |

**先只跑第一条**（38 MB）：能下完就说明旧清单还挂在 CDN 上，再接着跑后两条。
如果报 `manifest not found`，说明 Steam 撤了旧清单，这条路线作废。

下载落点 / where files land:

    D:\Steam\steamapps\content\app_489830\depot_489833\
    D:\Steam\steamapps\content\app_489830\depot_489831\
    D:\Steam\steamapps\content\app_489830\depot_489832\

合计约 20 GB，留够磁盘空间。

## 第 3 步：覆盖回游戏目录 / Step 3: copy them over

把三个目录里的**内容**（不是目录本身）合并复制到
`D:\Steam\steamapps\common\Skyrim Special Edition\`，同名覆盖，保持相对路径。

先备份现在的 `SkyrimSE.exe` / `SkyrimSELauncher.exe` / `steam_api64.dll` 更稳妥。

## 第 4 步：校验 / Step 4: verify

右键 `SkyrimSE.exe` → 属性 → 详细信息，文件版本应该是 **1.5.97.0**。

## 第 5 步：把 SKSE 也换回对应版本 / Step 5: swap SKSE

现在游戏目录里那份是给 1.7.104 的 **SKSE 2.3.1**（`skse64_1_7_104.dll`），必须换成
**SKSE64 2.0.20**（对应 1.5.97）：

1. 删掉 `skse64_1_7_104.dll`（其他名字里带 1_7_104 的也一并清掉）；
2. 从 `skse64_2_00_20.7z` 里取出 `skse64_1_5_97.dll`、`skse64_loader.exe`、
   `skse64_steam_loader.dll` 放进游戏目录，`Data\Scripts\*.pex` 覆盖进 `Data\Scripts\`。

官方直链（这个版本 silverlock 有直链）:

    https://skse.silverlock.org/beta/skse64_2_00_20.7z

## 第 6 步：别让 Steam 又升回去 / Step 6: stop Steam re-updating

1. 库 → 右键 Skyrim Special Edition → 属性 → 更新 → 「仅在我启动此游戏时更新」；
2. 以后一律双击 `skse64_loader.exe`（或本包的 `launch-skse.bat`）进游戏，
   **不要点 Steam 的「开始游戏」**。

## 第 7 步：必须无边框窗口 / Step 7: borderless is required

本层要在同一个窗口上建自己的交换链，**独占全屏下 DXGI 会拒绝**
（日志里表现为 `CreateSwapChainForHwnd -> 0x887a0001`，连续 3 次后本层放弃接管）。

`文档\My Games\Skyrim Special Edition\SkyrimPrefs.ini`：

```ini
[Display]
bBorderless=1
bFull Screen=0
```

> 用 MO2 的话改的应该是 **profile 里的**那份：
> `MO2\profiles\<你的配置>\skyrimprefs.ini`（MO2 用的是配置自带的 ini，不是文档目录那份）。

## 第 8 步：装回本 mod / Step 8: reinstall this pack

双击本包根目录的 `install.bat`。装之前脚本会核对 `SkyrimSE.exe` 版本，不是 1.5.97
会警告并要求你输入 `yes`。

## 备份与还原 / backup and rollback

- 想回到官方最新版：Steam 库里右键 → 属性 → 已安装文件 → 「验证游戏文件的完整性」，
  Steam 会把游戏拉回 1.7.104（SKSE 也要换回 2.3.1）。
- 本 mod 的一键停用/还原仍然是 `mfg-disable.bat` / `restore.bat`。
