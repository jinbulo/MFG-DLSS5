# Fallout 4 - 降回 1.10.163（Steam 控制台路线）
# Downgrading Fallout 4 back to 1.10.163 (Steam console route)

游戏目录 / Game folder: D:\Steam\steamapps\common\Fallout 4
当前版本 / Current build: 1.11.240（次世代更新，2026-10-05 17:19 被 Steam 自动升级）
目标版本 / Target build: 1.10.163（本 mod 与 F4SE 0.6.23 标定的版本）

## 为什么不能只换 exe / Why swapping only the exe is not enough

次世代更新把 BA2 档案头从 `BTDX v1` 改成了 `v7/v8`；1.10.163 的 exe 读不了新档案，
游戏会起不来。所以必须把整个旧版数据一起换回来。
The next-gen update bumped the BA2 header from `BTDX v1` to `v7/v8`; the 1.10.163
executable cannot read those archives, so the old data files must come back too.

## 第 1 步：打开 Steam 控制台 / Step 1: open the Steam console

在浏览器地址栏或 Win+R 里输入：

    steam://open/console

Steam 顶部会多出一个 CONSOLE 标签页。

## 第 2 步：逐条粘贴 / Step 2: paste these four lines, one at a time

    download_depot 377160 377162 5847529232406005096
    download_depot 377160 377161 7497069378349273908
    download_depot 377160 377163 5819088023757897745
    download_depot 377160 377164 2178106366609958945

说明 / what each depot is:

| depot | 内容 / contents | 体积 / size |
| --- | --- | --- |
| 377162 | Fallout4.exe + Fallout4Launcher.exe + steam_api64.dll | ~55 MB |
| 377161 | 主数据 a（Fallout4 - *.ba2 等） | ~6.1 GB |
| 377163 | 主数据 b（贴图 Textures1-9 等） | ~20.5 GB |
| 377164 | 英文语音 / English voices | ~3.8 GB |

先只跑第一条 / run only the first one first:
如果第一条 55 MB 的能下完，说明清单号还有效，再接着跑剩下三条。
如果报 "manifest not found"，说明 Steam 已经撤掉旧清单，这条路线作废，
改用第 6 步的自动工具。

下载落点 / where files land:

    D:\Steam\steamapps\content\app_377160\depot_377162\
    D:\Steam\steamapps\content\app_377160\depot_377161\
    D:\Steam\steamapps\content\app_377160\depot_377163\
    D:\Steam\steamapps\content\app_377160\depot_377164\

## 第 3 步：覆盖回游戏目录 / Step 3: copy the depots over the game folder

把上面四个目录里的**内容**（不是目录本身）合并复制到
`D:\Steam\steamapps\common\Fallout 4\`，同名就覆盖，保持相对路径。

需要的临时空间约 57 GB（旧数据 30 GB + 现有游戏 27 GB），D 盘现在有 82 GB 空闲，够。

## 第 4 步：校验 / Step 4: verify

右键 `Fallout4.exe` -> 属性 -> 详细信息，文件版本应该是 **1.10.163.0**。
（现在这里是 1.11.240.0。）

## 第 5 步：别让 Steam 又升回去 / Step 5: stop Steam re-updating

1. 库 -> 右键 Fallout 4 -> 属性 -> 更新 -> 选「仅在我启动此游戏时更新」。
2. 以后一律双击 `f4se_loader.exe` 进游戏，**不要**点 Steam 的「开始游戏」按钮
   （点它 Steam 会先把游戏更新回 1.11.240）。

## 第 6 步（可选）：自动工具 / Step 6 (optional): the automatic tool

如果控制台路线不好使，可用社区工具 Fallout 4 Downgrader：

    https://github.com/zerratar/fallout4-downgrader/releases
    （Nexus 上搜索 "Fallout 4 Downgrader" 也有它的页面）

它做的正是上面的下载 + 覆盖，另外还会给旧的 Fallout4.exe / Fallout4Launcher.exe /
steam_api64.dll 打小补丁，让 1.10.163 和现在的 Steam 客户端和平共处；支持 `-qr` 用
二维码登录，不必把密码输进第三方程序。上面的清单号就是从它的源码里取的。

## 第 7 步：装回本 mod / Step 7: reinstall this mod

1. 双击本包根目录的 `install.bat`（现在 MFG-tools 里的 mfg-tool.ps1 已带版本闸门，
   装之前会检查版本对不对）。
2. F4SE 0.6.23 已经装好在游戏目录了，不用重装。
3. 用 `f4se_loader.exe` 启动，进游戏后按 F11 可以一键隐藏/显示本 mod 的 UI。

## 可选的清理 / optional cleanup

降级后 `Data\` 里会剩下次世代带的 Creation Club 文件
（`ccBGSFO*.esl` / `ccBGSFO*.ba2` / `ccFSVFO*` / `ccOTMFO*` / `ccSBJFO*`）
和 `Fallout4 - TexturesPatch.ba2`。旧的 `Fallout4.ccc` 不会再引用它们，留着不影响
启动；想干净就删掉，但删之前确认没有用 MO2 装过依赖它们的 mod。

## 备份与还原 / backup and rollback

- 覆盖之前建议先把整个 `D:\Steam\steamapps\common\Fallout 4` 里的
  `Fallout4.exe` / `Fallout4Launcher.exe` / `steam_api64.dll` 三个文件另存一份。
- 想回到官方最新版：Steam 库里右键 Fallout 4 -> 属性 -> 已安装文件 ->
  「验证游戏文件的完整性」，Steam 会把游戏重新拉回 1.11.240。
