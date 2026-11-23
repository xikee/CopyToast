#!/usr/bin/env bash
# 构建 CopyToast.app，默认输出同时支持 Apple Silicon 与 Intel 的通用二进制。
# 用法：./scripts/build.sh [--single-arch] [--dmg]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

APP_NAME="CopyToast"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' Resources/Info.plist)"
DEPLOY_TARGET="14.0"
DIST="$ROOT/dist"
APP="$DIST/$APP_NAME.app"
UNIVERSAL=1
MAKE_DMG=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --single-arch) UNIVERSAL=0 ;;
    --dmg) MAKE_DMG=1 ;;
    *) echo "未知参数：$1" >&2; exit 2 ;;
  esac
  shift
done

if [[ ! -f Resources/AppIcon.icns ]]; then
  echo "==> 生成图标"
  mkdir -p build
  swiftc build/gen_icon.swift -framework AppKit -o build/gen_icon
  ./build/gen_icon > /dev/null
  iconutil -c icns build/icons.iconset -o Resources/AppIcon.icns
fi

echo "==> 编译 $APP_NAME $VERSION"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp Resources/Info.plist "$APP/Contents/Info.plist"

compile() {
  local arch="$1" output="$2"
  swiftc Sources/CopyToast/main.swift -o "$output" \
    -framework Cocoa -framework ServiceManagement -framework QuartzCore \
    -target "$arch-apple-macos$DEPLOY_TARGET" -O
}

if [[ $UNIVERSAL -eq 1 ]]; then
  compile arm64 "$DIST/.build-arm64"
  compile x86_64 "$DIST/.build-x86_64"
  lipo -create "$DIST/.build-arm64" "$DIST/.build-x86_64" \
    -output "$APP/Contents/MacOS/$APP_NAME"
  rm -f "$DIST/.build-arm64" "$DIST/.build-x86_64"
else
  compile "$(uname -m)" "$APP/Contents/MacOS/$APP_NAME"
fi

cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
xattr -cr "$APP"
codesign --force --sign - "$APP"
codesign --verify --strict "$APP"
echo "==> 应用：$APP"

if [[ $MAKE_DMG -eq 1 ]]; then
  STAGE="$DIST/dmg-root"
  DMG="$DIST/$APP_NAME-$VERSION.dmg"
  rm -rf "$STAGE" "$DMG"
  mkdir -p "$STAGE"
  cp -R "$APP" "$STAGE/"
  ln -s /Applications "$STAGE/Applications"
  hdiutil create -volname "$APP_NAME" -srcfolder "$STAGE" \
    -ov -quiet -format UDZO "$DMG"
  rm -rf "$STAGE"
  echo "==> 安装包：$DMG"
fi
