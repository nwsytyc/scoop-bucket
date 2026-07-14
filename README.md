# nwsytyc/scoop-bucket

Personal Scoop bucket — custom manifests + declarative package list for cross-machine sync.

## Quick Start (New Machine)

```powershell
# 1. Install Scoop (if not already)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
irm get.scoop.sh | iex

# 2. Add this bucket
scoop bucket add mybucket https://github.com/nwsytyc/scoop-bucket.git

# 3. One-shot full environment sync
powershell -File "$HOME\scoop\buckets\mybucket\setup.ps1"
```

Or with options:

```powershell
# Dry run (see what would be installed without actually doing it)
powershell -File setup.ps1 -DryRun

# Only add buckets, skip app installation
powershell -File setup.ps1 -SkipApps

# Only install apps (buckets already set up)
powershell -File setup.ps1 -SkipBuckets
```

## Update All Apps (Any Machine)

```powershell
scoop update --all
```

## Custom Manifests

Apps not available in any public Scoop bucket, maintained here:

| App | Description |
|-----|-------------|
| [workbuddy](workbuddy.json) | AI-native desktop Agent WorkBench (腾讯云 CodeBuddy) |
| [yuanbao](yuanbao.json) | 腾讯元宝 - AI智能助手，深度推理+联网搜索+划词搜索 |
| [thebrain](thebrain.json) | TheBrain - Visual knowledge network for notes, files, links, and AI |
| [updf](updf.json) | UPDF - AI-powered PDF editor |
| [typeless](typeless.json) | Typeless - Interactive storytelling platform |
| [vncviewer](vncviewer.json) | VNC Viewer - Control VNC enabled computers remotely (RealVNC) |
| [typora](typora.json) | Typora - Minimal Markdown editor and reader (mirrored from extras for faster updates) |

### Install individually

```powershell
scoop bucket add mybucket https://github.com/nwsytyc/scoop-bucket.git
scoop install mybucket/workbuddy
scoop install mybucket/yuanbao
scoop install mybucket/thebrain
scoop install mybucket/updf
scoop install mybucket/typeless
scoop install mybucket/vncviewer
scoop install mybucket/typora
```

## Package List

The full app suite is declared in [packages.json](packages.json) — 100+ apps across 12 buckets.

| Bucket | Apps | Count |
|--------|------|-------|
| main | 1password-cli, 7zip, aria2, bbdown, bun, cacert, clink, cmder, claude-code, codex, curl, dark, deepseek-tui, edit, ffmpeg, gh, git, gow, innounp, kimi-cli, lsd, neovim, nodejs-lts, oh-my-posh, oh-my-pi, opencode, python, scoop-search, sudo, tldr, wget, warp, yt-dlp | 33 |
| extras | anki, beyondcompare, calibre, carotdav, cc-switch, clash-party, cupscale, discord, ditto, dropit, emacs, everything, fastcopy, flow-launcher, foobar2000, foobar2000-encoders, fork, freetube, gimp, glazewm, googlechrome, homebank, joplin, listary, logseq, motrix, neeview, notion, obsidian, opera, potplayer, q-dir, qq, qview, retroarch, sharpkeys, slack, snipaste, telegram, tightvnc, treesheets, unlocker, vscode, wechat, wecom, wireshark, wox, xnview, zebar, zed, zen-browser | 52 |
| versions | innounp-unicode, nodejs20 | 2 |
| sysinternals | process-explorer, pstools | 2 |
| nonportable | zerotier-np | 1 |
| games | eden, sak, steam | 3 |
| dorado | powershell | 1 |
| extras-cn | blender-cn, eudic, pixpin, tencent-meeting, tim, vlc-cn, weasel | 7 |
| extras-plus | comfyui | 1 |
| go-musicfox | go-musicfox | 1 |
| main-plus | sendme | 1 |
| mybucket | workbuddy, yuanbao, thebrain, updf, typeless, vncviewer, typora | 7 |
| **winget** | Tencent.ima-copilot, Tencent.Yuanbao | 2 |
| **Total** | | **114** |

### Held Packages

| App | Version | Note |
|-----|---------|------|
| comfyui | 0.3.66 | Locked to specific version |

## How It Works

- **Custom manifests** (workbuddy, yuanbao, thebrain) live in this repo — `scoop install mybucket/<app>` pulls from here
- **Public bucket apps** stay in their upstream buckets — no duplication, auto-updates flow from upstream
- **winget apps** (ima) — some apps don't have stable Scoop-compatible download URLs, so they go through winget instead
- **packages.json** is the declarative source of truth for the full app list
- **setup.ps1** reads packages.json and installs everything in one shot (Scoop + winget)

## Adding a New App

1. If it's in a public bucket: add to the appropriate list in `packages.json`
2. If it's custom (no public manifest): create a `.json` manifest here, add to `mybucket` list in `packages.json`
3. Commit & push — all machines can sync via `scoop update`

## Notes

- **WorkBuddy**: The official Extras-CN bucket uses `innounp` for Inno Setup format, but newer versions (>=5.1.7) switched to NSIS. This manifest handles NSIS extraction properly.
- **opencode**: Now available in the `main` bucket — no longer needs a custom manifest here.
- **元宝 (yuanbao)**: CDN URL `yuanbao_10046_x64.exe` 不含版本号，始终指向最新版。新版本发布后需手动更新 hash（运行 `scoop install mybucket/yuanbao` 时 Scoop 会自动下载最新 exe，但 hash 校验会失败，需要手动更新 yuanbao.json 中的 hash 和 version）。
- **ima**: 下载 URL 通过 API 动态生成，无法创建稳定 Scoop manifest。通过 winget 安装 (`winget install Tencent.ima-copilot`)。
- **TheBrain**: 下载 URL `salesapi.thebrain.com/?a=doDirectDownload&id=15002` 是 API 重定向，始终指向最新版 NSIS 安装包。新版本发布后需手动更新 hash。
- **VNC Viewer (vncviewer)**: RealVNC 官方已停止提供独立 EXE 下载，现仅提供 MSI 安装包（RealVNC-Connect-Viewer-x.x.x-Windows.msi.zip）。使用 lessmsi 提取 MSI 内容。版本号通过 checkver 从官网下载页面获取。
- **Typora (typora)**: 镜像自 extras 桶，因为官方源更新较慢导致 app 内部一直提示更新。本桶直接从 `download.typora.io` 拉取最新版本。
