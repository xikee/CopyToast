# CopyToast · 复制成功提示

[![CI](https://github.com/xikee/CopyToast/actions/workflows/ci.yml/badge.svg)](https://github.com/xikee/CopyToast/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/xikee/CopyToast)](https://github.com/xikee/CopyToast/releases/latest)
[![License](https://img.shields.io/github/license/xikee/CopyToast)](LICENSE)

macOS 14+ 菜单栏小工具：复制后在鼠标附近弹出「已复制」胶囊提示，1.4 秒自动消失。

## 下载安装

1. 从 [Releases](https://github.com/xikee/CopyToast/releases/latest) 下载最新的 `CopyToast-x.y.z.dmg`
2. 打开 DMG，将 CopyToast 拖入「应用程序」
3. 首次启动若提示「无法验证开发者」，右键点击图标后选择「打开」

应用使用 ad-hoc 签名，未经过 Apple 公证。也可以在终端移除隔离标记：

```bash
xattr -dr com.apple.quarantine /Applications/CopyToast.app
```

## 特性

- 纯后台运行，无 Dock 图标，仅在菜单栏留一个小图标
- 提示浮于所有窗口之上，**不抢焦点、不拦截点击**，用完即走
- 智能识别内容类型：✓文本 / 🔗链接 / 🖼图片 / 📄文件 / 🔒敏感内容
- **零隐私打扰**：只读取剪贴板的「类型」，绝不读取内容本身，因此不会触发 macOS 14 的「想要从其他 App 粘贴」弹窗
- 密码管理器复制敏感内容时会显示 🔒 提示但不展示具体内容
- 连续复制时提示原地更新，不闪烁

## 使用

菜单栏图标 →

- **登录时启动**：勾选后随用户登录自动运行。如显示「等待系统批准…」，点击即可打开系统设置中的登录项。
- **退出**：完全退出应用

## 隐私

- 只读取 `NSPasteboard` 的类型元数据，从不读取剪贴板正文
- 不联网、不写日志、不保留复制历史
- 无需辅助功能、屏幕录制等系统权限

## 系统要求

macOS 14 Sonoma 或更高版本，支持 Apple Silicon 与 Intel。

## 从源码构建

需要安装 Xcode 命令行工具（`xcode-select --install`）。

```bash
./scripts/test.sh          # 回归测试
./scripts/build.sh --dmg   # 通用版 .app 与 DMG，输出到 dist/
```

只构建当前架构可用 `./scripts/build.sh --single-arch`。

## 项目结构

```
Sources/CopyToast/main.swift   应用全部逻辑
Tests/RegressionTests.swift    无第三方依赖的回归测试
Resources/Info.plist           应用配置与版本号
build/gen_icon.swift           AppKit 绘制图标
scripts/                       测试与构建脚本
```

## 技术

- 纯 Swift + AppKit，无第三方依赖，无 Xcode 工程
- 每 0.25s 轮询 `NSPasteboard.changeCount`（系统提供的变化计数，开销极小）
- 源码：`Sources/CopyToast/main.swift`（单文件）
- 构建：`swiftc` 直接编译 + `lipo` 合并通用二进制 + ad-hoc 签名
- CI：GitHub Actions 在 macOS 14 上运行测试并构建 DMG

## 发布

```bash
git tag -a v1.0.0 -m "CopyToast 1.0.0"
git push origin main --tags
gh release create v1.0.0 dist/CopyToast-1.0.0.dmg \
  --title "CopyToast 1.0.0" --generate-notes
```

版本号同时维护在 `Resources/Info.plist` 和 [CHANGELOG.md](CHANGELOG.md)。

## 许可证

[MIT](LICENSE)
