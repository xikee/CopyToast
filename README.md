# CopyToast · 复制成功提示

macOS 14 轻量工具：复制（⌘C）成功后在鼠标附近弹出「已复制」胶囊提示，1.4 秒自动消失。

## 特性

- 纯后台运行，无 Dock 图标，仅在菜单栏留一个小图标
- 提示浮于所有窗口之上，**不抢焦点、不拦截点击**，用完即走
- 智能识别内容类型：✓文本 / 🔗链接 / 🖼图片 / 📄文件 / 🔒敏感内容
- **零隐私打扰**：只读取剪贴板的「类型」，绝不读取内容本身，因此不会触发 macOS 14 的「想要从其他 App 粘贴」弹窗
- 密码管理器复制敏感内容时会显示 🔒 提示但不展示具体内容
- 连续复制时提示原地更新，不闪烁

## 使用

双击 `/Applications/CopyToast.app` 即开始工作，无需任何配置。

菜单栏图标 →
- **登录时启动**：勾选后随用户登录自动运行。如显示「等待系统批准…」，点击即可打开系统设置中的登录项。
- **退出**：完全退出应用

## 卸载

退出应用后，把 `/Applications/CopyToast.app` 拖进废纸篓即可。无任何后台残留。

## 项目结构

```
Sources/CopyToast/main.swift   应用全部逻辑
Tests/RegressionTests.swift    无第三方依赖的回归测试
Resources/Info.plist           应用配置
build/gen_icon.swift           AppKit 绘制图标
```

## 技术

- 纯 Swift + AppKit，无第三方依赖，无 Xcode 工程
- 每 0.25s 轮询 `NSPasteboard.changeCount`（系统提供的变化计数，开销极小）
- 源码：`Sources/CopyToast/main.swift`（单文件）
- 构建：`swiftc` 直接编译 + ad-hoc 签名

## 重新构建

仓库不收录二进制产物（`.app`、`.icns`、预览图）。首次构建或修改图标后，先在仓库根目录生成图标：

```bash
swiftc build/gen_icon.swift -framework AppKit -o build/gen_icon && ./build/gen_icon
iconutil -c icns build/icons.iconset -o Resources/AppIcon.icns
```

然后编译并打包：

```bash
mkdir -p CopyToast.app/Contents/MacOS CopyToast.app/Contents/Resources
swiftc Sources/CopyToast/main.swift \
  -o CopyToast.app/Contents/MacOS/CopyToast \
  -framework Cocoa -framework ServiceManagement -framework QuartzCore \
  -target arm64-apple-macos14.0 -O
cp Resources/Info.plist CopyToast.app/Contents/Info.plist
cp Resources/AppIcon.icns CopyToast.app/Contents/Resources/AppIcon.icns
xattr -cr CopyToast.app
codesign --force --deep --sign - CopyToast.app
```

Intel 机器将 `arm64-apple-macos14.0` 换成 `x86_64-apple-macos14.0`；需要同时支持两种架构时可用 `lipo` 合并。

运行回归测试（使用构造的剪贴板类型和登录项状态）：

```bash
swiftc -D COPYTOAST_TESTS Sources/CopyToast/main.swift Tests/RegressionTests.swift -o build/CopyToastTests && build/CopyToastTests
```

调试模式（终端可见内部日志）：

```bash
/Applications/CopyToast.app/Contents/MacOS/CopyToast --debug
```
